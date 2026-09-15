import '../models/models.dart';
import 'mock_data.dart';

/// Chat Completions tool ("function") definitions the MBMT Assistant can call.
class AiTools {
  AiTools._();

  static const Map<String, dynamic> planTrip = <String, dynamic>{
    'type': 'function',
    'function': <String, dynamic>{
      'name': 'plan_trip',
      'description':
          'Plan a door-to-door MBMT trip from an origin to a destination. Combines bus legs, '
          'a bus change if needed, and a short walk or auto-rickshaw leg where no bus route is '
          'known. Call this as soon as you know the destination the user wants to reach - never '
          'work out the route yourself.',
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
}

/// Builds the grounding system prompts sent to OpenAI. Keeping every route,
/// fare and pass fact in the prompt (and requiring the trip-planning tool for
/// the actual routing) is what stops the model from inventing bus numbers
/// that do not exist in this prototype.
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

  /// System prompt for the main "MBMT Assistant" trip-planning conversation.
  static String tripPlannerSystemPrompt({
    required String languageCode,
    required String currentLocationStop,
  }) {
    final String lang = languageName(languageCode);
    return '''
You are "MBMT Assistant", the in-app trip-planning agent for a proposed redesign of Mira-Bhayandar Municipal Transport (MBMT). This is a student project prototype - all data below is sample data, never claim it is live, official or real-time.

How to behave:
- Be warm, brief and practical - 2 to 5 sentences per reply, except when laying out a finished itinerary step by step.
- If you do not yet know where the user wants to go, ask them.
- Their current default starting point is "$currentLocationStop". Use it as the origin unless they name a different starting point.
- As soon as you know a destination, call the plan_trip tool with that destination (and the origin, if the user gave a different one). Never work out bus numbers, stops or fares yourself - always use the tool, then explain exactly what it returned.
- When you have the tool's result, explain it as clear directions in order: which bus to board and where, when to change buses if there is a change, and when to walk. State the total time and total fare.
- If the tool result is marked as an estimate (no direct MBMT bus route known in this prototype), say that plainly and offer the suggested auto-rickshaw option without pretending the numbers are precise.
- If asked about something unrelated to MBMT buses, routes, fares or passes, politely say that's outside what this prototype can help with.
- Reply in $lang. If the user writes in a different language, still reply in $lang unless they clearly ask you to switch languages.

Known MBMT routes in this prototype (for your reference only - always confirm the real path via plan_trip):
${_busSummary()}
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
