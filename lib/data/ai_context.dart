import '../models/models.dart';
import 'bus_stops.dart';
import 'mock_data.dart';

/// Chat Completions tool ("function") definitions the MBMT Assistant can call.
class AiTools {
  AiTools._();

  static const Map<String, dynamic> planTrip = <String, dynamic>{
    'type': 'function',
    'function': <String, dynamic>{
      'name': 'plan_trip',
      'description':
          'Plan a door-to-door MBMT trip from an origin to a destination. Returns several '
          'realistic ways to make the trip under "options" - like a maps app\'s mode picker - '
          'covering a bus/transit route (direct, or with one change) when one exists, plus an '
          'auto-rickshaw estimate and a walking estimate, each with its own duration_min and '
          'fare_inr computed from real stop data and coordinates. Call this as soon as you know '
          'the destination the user wants to reach - never work out the route yourself.',
      'parameters': <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'origin': <String, dynamic>{
            'type': 'string',
            'description':
                'Starting stop, station or area. Omit or leave blank to use the user\'s current '
                'default location.',
          },
          'destination': <String, dynamic>{
            'type': 'string',
            'description': 'Where the user wants to go - a stop, station, landmark or area name.',
          },
        },
        'required': <String>['destination'],
      },
    },
  };

  static const Map<String, dynamic> bookTicket = <String, dynamic>{
    'type': 'function',
    'function': <String, dynamic>{
      'name': 'book_ticket',
      'description':
          'Book a digital MBMT ticket for a direct, single-bus (no-transfer) trip the user has '
          'explicitly confirmed. Always confirm the origin, destination, bus, fare and passenger '
          'count with the user first - never call this without a clear yes. If the best plan from '
          'plan_trip needed a bus change, or was only an auto-rickshaw estimate, explain that a '
          'single ticket cannot be booked for it in this prototype instead of calling this tool.',
      'parameters': <String, dynamic>{
        'type': 'object',
        'properties': <String, dynamic>{
          'origin': <String, dynamic>{
            'type': 'string',
            'description':
                'Boarding stop. Omit or leave blank to use the user\'s current default location.',
          },
          'destination': <String, dynamic>{
            'type': 'string',
            'description': 'Alighting stop.',
          },
          'passengers': <String, dynamic>{
            'type': 'integer',
            'description': 'Number of adult tickets to book. Defaults to 1 if not stated.',
          },
        },
        'required': <String>['destination'],
      },
    },
  };
}

/// Builds the grounding system prompts sent to OpenAI. Keeping every route,
/// stop and pass fact in the prompt (and requiring tools for the actual
/// routing / booking) is what stops the model from inventing bus numbers,
/// places or tickets that do not exist in this prototype.
class AiContext {
  AiContext._();

  static String languageName(String code) {
    switch (code) {
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      default:
        return 'English';
    }
  }

  static String _busSummary() {
    return MockData.nearbyBuses
        .map((Bus b) =>
            '- Bus ${b.number}: ${b.origin} to ${b.destination}, via ${b.via}. '
            'Full-route fare Rs.${b.fare}, ${b.frequencyLabel}, service ${b.serviceHoursLabel}.')
        .join('\n');
  }

  static String _passSummary() {
    return MockData.passes
        .map((TransitPass p) => '- ${p.type}: Rs.${p.price} (${p.validity}).')
        .join('\n');
  }

  /// Every real stop grouped by area, name only (routes are already covered
  /// by [_busSummary]). This is what lets the assistant recognise places like
  /// "Maxus Mall" or "K.D. Empire" that only ever appear as an intermediate
  /// halt, not as any route's origin/destination/via text.
  static String _stopDirectory() {
    final Map<String, List<String>> byArea = <String, List<String>>{};
    for (final RealStop s in kRealStops) {
      byArea.putIfAbsent(s.area, () => <String>[]).add(s.name);
    }
    return byArea.entries
        .map((MapEntry<String, List<String>> e) => '${e.key}: ${e.value.join(', ')}')
        .join('\n');
  }

  /// System prompt for the main "MBMT Assistant" trip-planning + booking
  /// conversation.
  static String tripPlannerSystemPrompt({
    required String languageCode,
    required String currentLocationStop,
  }) {
    final String lang = languageName(languageCode);
    return '''
You are "MBMT Assistant", the in-app trip-planning and booking agent for a proposed redesign of Mira-Bhayandar Municipal Transport (MBMT). This is a student project prototype - all data below is sample data, never claim it is live, official or real-time.

How to behave:
- Be warm, brief and practical - 2 to 5 sentences per reply, except when laying out a finished itinerary step by step.
- If you do not yet know where the user wants to go, ask them.
- Their current default starting point is "$currentLocationStop". Use it as the origin unless they name a different starting point.
- As soon as you know a destination, call the plan_trip tool with that destination (and the origin, if the user gave a different one). Never work out bus numbers, stops or fares yourself - always use the tool, then explain exactly what it returned.
- The tool returns a list under "options" - like a maps app's mode picker (bus/transit, auto-rickshaw, walk), each with its own duration_min and fare_inr. First give a one-line summary of every option so the user can compare at a glance (e.g. "Bus 29: 32 min, Rs.22 · Auto-rickshaw: ~14 min, Rs.90 · Walk: ~46 min, free"), then give full step-by-step directions (which bus to board and where, when to change buses, when to walk) for whichever option best fits what they asked for - normally the bus/transit option when one exists, unless they asked for the fastest, cheapest, or a specific mode.
- If an option's is_estimate is true (walk or auto-rickshaw, since no MBMT bus route was known for it), say plainly that it is a rough estimate based on straight-line distance between stops, not a live quote or a scheduled MBMT service.
- If the user wants to book after seeing a plan, confirm the origin, destination, bus, fare and number of passengers with them, then call book_ticket. Only direct (single-bus) trips can be booked in this prototype - say so if the plan needed a change or was only an estimate. After a successful booking, tell the user it's booked, mention the ticket ID, and that it's saved under My Tickets with a QR code for the conductor.
- If asked about something unrelated to MBMT buses, routes, fares, passes or bookings, politely say that's outside what this prototype can help with.
- Reply in $lang. If the user writes in a different language, still reply in $lang unless they clearly ask you to switch languages.

Known MBMT routes in this prototype (for your reference only - always confirm the real path via plan_trip):
${_busSummary()}

Known stops and areas MBMT serves in this prototype, by area (for recognising place names only - always confirm via plan_trip):
${_stopDirectory()}
''';
  }

  /// Lighter system prompt for the Help & Support inline Q&A (no tool use).
  static String helpSystemPrompt({required String languageCode}) {
    final String lang = languageName(languageCode);
    return '''
You are the MBMT Smart Bus in-app help assistant for a student project prototype of a redesigned Mira-Bhayandar Municipal Transport app. All data below is sample data, not a live feed - never claim otherwise.

Answer the user's support question in 2-4 short sentences using only the facts below. If it is outside this scope, say you can only help with MBMT routes, fares, passes and using this app, and suggest they check the FAQ list on this screen. Reply in $lang.

Routes:
${_busSummary()}

Passes:
${_passSummary()}
''';
  }
}
