import 'trip_models.dart';

enum AiRole { user, assistant }

/// One rendered turn in the MBMT Assistant chat. [itinerary] is attached to
/// assistant turns where the trip-planning tool was used, so the UI can show
/// a rich step-by-step card alongside the model's natural-language reply.
class AiChatMessage {
  final AiRole role;
  final String content;
  final TripItinerary? itinerary;

  const AiChatMessage({
    required this.role,
    required this.content,
    this.itinerary,
  });

  String get apiRole => role == AiRole.user ? 'user' : 'assistant';
}
