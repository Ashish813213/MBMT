import '../data/ai_context.dart';
import '../models/ai_chat_message.dart';
import '../models/models.dart';
import '../models/trip_models.dart';
import 'ai_service.dart';
import 'trip_planner.dart';

/// Issues a real ticket for a confirmed booking and returns it. Implemented
/// by the UI layer (it needs [AppState]) and passed into [TripAgent.respond].
typedef BookTicketCallback = Ticket Function({
  required String from,
  required String to,
  required String busNumber,
  required int fare,
  required int passengers,
});

/// The result of one assistant turn: the natural-language reply, plus a
/// structured set of itinerary options (Bus / Auto-rickshaw / Walk, maps-app
/// style) and/or a booked ticket when a tool was used this turn.
class AiTurnResult {
  final String reply;
  final List<TripItinerary>? itineraries;
  final Ticket? ticket;
  const AiTurnResult({required this.reply, this.itineraries, this.ticket});
}

/// Wires the OpenAI conversation to the local, deterministic [TripPlanner] via
/// Chat Completions tool-calling: the model handles greeting, understanding
/// the destination, phrasing directions and confirming bookings, while every
/// bus number, stop, fare and ticket it talks about comes from [TripPlanner]
/// or a real issued [Ticket] - never invented.
class TripAgent {
  List<TripItinerary>? _lastItineraries;
  Ticket? _lastTicket;

  Future<AiTurnResult> respond({
    required List<AiChatMessage> history,
    required String userMessage,
    required String languageCode,
    required String currentLocationStop,
    required BookTicketCallback onBookTicket,
  }) async {
    _lastItineraries = null;
    _lastTicket = null;

    final String reply = await AiService.instance.chatWithTools(
      systemPrompt: AiContext.tripPlannerSystemPrompt(
        languageCode: languageCode,
        currentLocationStop: currentLocationStop,
      ),
      history: history,
      userMessage: userMessage,
      tools: <Map<String, dynamic>>[AiTools.planTrip, AiTools.bookTicket],
      onToolCall: (String name, Map<String, dynamic> args) async {
        switch (name) {
          case 'plan_trip':
            return _handlePlanTrip(args, currentLocationStop);
          case 'book_ticket':
            return _handleBookTicket(args, currentLocationStop, onBookTicket);
          default:
            return <String, dynamic>{'error': 'Unknown tool: $name'};
        }
      },
    );

    return AiTurnResult(reply: reply, itineraries: _lastItineraries, ticket: _lastTicket);
  }

  Map<String, dynamic> _handlePlanTrip(Map<String, dynamic> args, String currentLocationStop) {
    final String rawOrigin = (args['origin'] as String? ?? '').trim();
    final String rawDestination = (args['destination'] as String? ?? '').trim();
    final String origin = rawOrigin.isEmpty ? currentLocationStop : rawOrigin;

    final List<TripItinerary> options = TripPlanner.instance.planModes(origin, rawDestination);
    _lastItineraries = options;
    return <String, dynamic>{
      'options': options.map((TripItinerary i) => i.toJson()).toList(),
    };
  }

  Map<String, dynamic> _handleBookTicket(
    Map<String, dynamic> args,
    String currentLocationStop,
    BookTicketCallback onBookTicket,
  ) {
    final String rawOrigin = (args['origin'] as String? ?? '').trim();
    final String destination = (args['destination'] as String? ?? '').trim();
    final String origin = rawOrigin.isEmpty ? currentLocationStop : rawOrigin;
    final int passengers = (((args['passengers'] as num?)?.toInt() ?? 1)).clamp(1, 6);

    final TripItinerary itinerary = TripPlanner.instance.plan(origin, destination);
    final List<TripLeg> busLegs =
        itinerary.legs.where((TripLeg l) => l.mode == TravelMode.bus).toList();

    if (busLegs.length != 1 || busLegs.first.busNumber == null) {
      final String reason = itinerary.isEstimate
          ? 'No MBMT bus route is known between these stops in this prototype, so a ticket '
              'cannot be booked - only the estimated walking or auto-rickshaw option is available.'
          : busLegs.length > 1
              ? 'This trip needs a bus change, so a single ticket cannot be booked for the whole '
                  'journey in this prototype. Book the first leg, then a fresh ticket after '
                  'changing buses.'
              : 'This trip has no bus leg to book.';
      return <String, dynamic>{'success': false, 'reason': reason};
    }

    final TripLeg leg = busLegs.first;
    final Ticket ticket = onBookTicket(
      from: itinerary.originResolved,
      to: itinerary.destinationResolved,
      busNumber: leg.busNumber!,
      fare: leg.fare,
      passengers: passengers,
    );
    _lastTicket = ticket;

    return <String, dynamic>{
      'success': true,
      'ticket_id': ticket.id,
      'route': 'Bus ${ticket.route}',
      'from': ticket.from,
      'to': ticket.to,
      'total_fare_inr': ticket.fare,
      'passengers': ticket.passengers,
      'date': ticket.date,
      'time': ticket.time,
    };
  }
}
