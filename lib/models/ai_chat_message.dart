import 'models.dart';
import 'trip_models.dart';

enum AiRole { user, assistant }

/// One rendered turn in the MBMT Assistant chat. [itineraries] is attached to
/// assistant turns where the trip-planning tool was used - a maps-app-style
/// list of mode options (Bus / Auto-rickshaw / Walk) for the same trip - and
/// [ticket] when the booking tool successfully issued a ticket, so the UI can
/// show a rich card alongside the model's natural-language reply.
class AiChatMessage {
  final AiRole role;
  final String content;
  final List<TripItinerary>? itineraries;
  final Ticket? ticket;

  const AiChatMessage({
    required this.role,
    required this.content,
    this.itineraries,
    this.ticket,
  });

  String get apiRole => role == AiRole.user ? 'user' : 'assistant';
}
