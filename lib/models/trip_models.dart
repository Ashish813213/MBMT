/// How a leg of a planned trip is covered.
enum TravelMode { bus, walk, rickshaw }

/// One step of a door-to-door itinerary - e.g. "board Bus 45A", or a short
/// walking / auto-rickshaw connector between two stops.
class TripLeg {
  final TravelMode mode;
  final String from;
  final String to;
  final String? busNumber;
  final int durationMin;
  final int fare;
  final String instruction;

  const TripLeg({
    required this.mode,
    required this.from,
    required this.to,
    required this.durationMin,
    required this.fare,
    required this.instruction,
    this.busNumber,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mode': mode.name,
        'from': from,
        'to': to,
        if (busNumber != null) 'bus_number': busNumber,
        'duration_min': durationMin,
        'fare_inr': fare,
        'instruction': instruction,
      };
}

/// A full, deterministically-computed trip plan from an origin to a
/// destination across the MBMT network in [MockData]. Built entirely in Dart
/// (no AI involved) so bus numbers, stops and fares are always consistent
/// with the rest of the prototype - the AI only explains this result, it
/// never invents the route itself.
class TripItinerary {
  final String originResolved;
  final String destinationResolved;
  final List<TripLeg> legs;
  final int totalDurationMin;
  final int totalFare;

  /// True when no MBMT bus route connects the two points within one
  /// transfer in this prototype's network, so the plan falls back to an
  /// estimated walk / auto-rickshaw leg instead of a real bus leg.
  final bool isEstimate;

  const TripItinerary({
    required this.originResolved,
    required this.destinationResolved,
    required this.legs,
    required this.totalDurationMin,
    required this.totalFare,
    required this.isEstimate,
  });

  bool get isSamePlace => legs.isEmpty;

  int get changeCount => legs.where((TripLeg l) => l.mode == TravelMode.bus).length > 1
      ? legs.where((TripLeg l) => l.mode == TravelMode.bus).length - 1
      : 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'origin': originResolved,
        'destination': destinationResolved,
        'total_duration_min': totalDurationMin,
        'total_fare_inr': totalFare,
        'is_estimate': isEstimate,
        'legs': legs.map((TripLeg l) => l.toJson()).toList(),
      };
}
