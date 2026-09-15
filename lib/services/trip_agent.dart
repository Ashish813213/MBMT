import '../data/ai_context.dart';
import '../models/ai_chat_message.dart';
import '../models/trip_models.dart';
import 'ai_service.dart';
import 'trip_planner.dart';

/// The result of one assistant turn: the natural-language reply, plus a
/// structured itinerary when the trip-planning tool was used this turn.
class AiTurnResult {
  final String reply;
  final TripItinerary? itinerary;
  const AiTurnResult({required this.reply, this.itinerary});
}

/// Wires the OpenAI conversation to the local, deterministic [TripPlanner] via
/// Chat Completions tool-calling: the model handles greeting, understanding
/// the destination and phrasing directions, while every bus number, stop and
/// fare it talks about comes from [TripPlanner.plan] - never invented.
class TripAgent {
  TripItinerary? _lastItinerary;

  Future<AiTurnResult> respond({
    required List<AiChatMessage> history,
    required String userMessage,
    required String languageCode,
    required String currentLocationStop,
  }) async {
    _lastItinerary = null;

    final String reply = await AiService.instance.chatWithTool(
      systemPrompt: AiContext.tripPlannerSystemPrompt(
        languageCode: languageCode,
        currentLocationStop: currentLocationStop,
      ),
      history: history,
      userMessage: userMessage,
      tool: AiTools.planTrip,
      onToolCall: (Map<String, dynamic> args) {
        final String rawOrigin = (args['origin'] as String? ?? '').trim();
        final String rawDestination = (args['destination'] as String? ?? '').trim();
        final String origin = rawOrigin.isEmpty ? currentLocationStop : rawOrigin;
        final TripItinerary itinerary = TripPlanner.instance.plan(origin, rawDestination);
        _lastItinerary = itinerary;
        return itinerary.toJson();
      },
    );

    return AiTurnResult(reply: reply, itinerary: _lastItinerary);
  }
}
