import '../data/mock_data.dart';
import '../models/models.dart';
import '../models/trip_models.dart';

/// A small, deterministic, pure-Dart trip planner over the MBMT bus network
/// described in [MockData]. No AI is involved in computing the route itself -
/// this graph search finds real bus numbers, real stop names and prorated
/// fares/durations from the app's own data, and falls back to a clearly
/// labelled estimated auto-rickshaw leg when no bus path is known.
///
/// The AI assistant calls [plan] as a tool and only explains the result in
/// natural language - it never invents a bus number or stop on its own.
class TripPlanner {
  TripPlanner._();
  static final TripPlanner instance = TripPlanner._();

  TripItinerary plan(String rawOrigin, String rawDestination) {
    final String origin = _resolveStop(rawOrigin);
    final String destination = _resolveStop(rawDestination);

    if (origin.isEmpty || destination.isEmpty) {
      return _rickshawFallback(
        origin.isEmpty ? rawOrigin.trim() : origin,
        destination.isEmpty ? rawDestination.trim() : destination,
      );
    }

    if (origin.toLowerCase() == destination.toLowerCase()) {
      return TripItinerary(
        originResolved: origin,
        destinationResolved: destination,
        legs: const <TripLeg>[],
        totalDurationMin: 0,
        totalFare: 0,
        isEstimate: false,
      );
    }

    if (!_isKnownStop(origin) || !_isKnownStop(destination)) {
      return _rickshawFallback(origin, destination);
    }

    // 1) A single bus that passes through both, in the right order.
    for (final Bus b in MockData.nearbyBuses) {
      final int i = _indexOfStop(b.stops, origin);
      final int j = _indexOfStop(b.stops, destination);
      if (i != -1 && j != -1 && i < j) {
        return _singleBusItinerary(b, origin, destination, i, j);
      }
    }

    // 2) One transfer: bus A from origin to a shared stop, bus B from there
    //    on to the destination.
    final List<Bus> fromOrigin = _busesThrough(origin);
    final List<Bus> toDestination = _busesThrough(destination);
    TripItinerary? best;

    for (final Bus a in fromOrigin) {
      final int oi = _indexOfStop(a.stops, origin);
      if (oi == -1) continue;

      for (final Bus b in toDestination) {
        if (a.number == b.number) continue;
        final int dj = _indexOfStop(b.stops, destination);
        if (dj == -1) continue;

        for (int k = oi + 1; k < a.stops.length; k++) {
          final String mid = a.stops[k];
          final int bj = _indexOfStop(b.stops, mid);
          if (bj != -1 && bj < dj) {
            final TripItinerary candidate =
                _twoBusItinerary(a, b, origin, mid, destination, oi, k, bj, dj);
            if (best == null || candidate.totalDurationMin < best.totalDurationMin) {
              best = candidate;
            }
            break;
          }
        }
      }
    }
    if (best != null) return best;

    // 3) Nothing found within one transfer in this prototype's network.
    return _rickshawFallback(origin, destination);
  }

  // --- stop resolution ------------------------------------------------------

  String _resolveStop(String raw) {
    final String q = raw.trim();
    if (q.isEmpty) return q;
    final String ql = q.toLowerCase();

    for (final String s in MockData.stops) {
      if (s.toLowerCase() == ql) return s;
    }
    for (final String s in MockData.stops) {
      final String sl = s.toLowerCase();
      if (sl.contains(ql) || ql.contains(sl)) return s;
    }

    final Set<String> qWords =
        ql.split(RegExp(r'[\s,()]+')).where((String w) => w.length > 2).toSet();
    String? best;
    int bestScore = 0;
    for (final String s in MockData.stops) {
      final Set<String> sWords =
          s.toLowerCase().split(RegExp(r'[\s,()]+')).where((String w) => w.length > 2).toSet();
      final int score = qWords.intersection(sWords).length;
      if (score > bestScore) {
        bestScore = score;
        best = s;
      }
    }
    return best ?? q;
  }

  bool _isKnownStop(String s) =>
      MockData.stops.any((String x) => x.toLowerCase() == s.toLowerCase());

  List<Bus> _busesThrough(String stop) => MockData.nearbyBuses
      .where((Bus b) => b.stops.any((String s) => s.toLowerCase() == stop.toLowerCase()))
      .toList();

  int _indexOfStop(List<String> stops, String name) =>
      stops.indexWhere((String s) => s.toLowerCase() == name.toLowerCase());

  // --- itinerary construction ------------------------------------------------

  int _fareFor(int fullFare, int legStops, int totalLegs) {
    if (totalLegs <= 0) return fullFare;
    final int prorated = (fullFare * legStops / totalLegs).round();
    return prorated < 10 ? 10 : prorated;
  }

  TripItinerary _singleBusItinerary(Bus b, String origin, String destination, int i, int j) {
    final int totalLegs = b.stops.length - 1;
    final int legStops = j - i;
    final int rawDuration =
        totalLegs <= 0 ? b.runningTimeMin : (b.runningTimeMin * legStops / totalLegs).round();
    final int duration = rawDuration < 4 ? 4 : rawDuration;
    final int fare = _fareFor(b.fare, legStops, totalLegs);

    return TripItinerary(
      originResolved: origin,
      destinationResolved: destination,
      legs: <TripLeg>[
        TripLeg(
          mode: TravelMode.bus,
          from: origin,
          to: destination,
          busNumber: b.number,
          durationMin: duration,
          fare: fare,
          instruction: 'Board Bus ${b.number} at $origin and stay on till $destination '
              '(${b.frequencyLabel}, ${b.serviceHoursLabel}).',
        ),
      ],
      totalDurationMin: duration,
      totalFare: fare,
      isEstimate: false,
    );
  }

  TripItinerary _twoBusItinerary(
    Bus a,
    Bus b,
    String origin,
    String mid,
    String destination,
    int oi,
    int ai,
    int bi,
    int dj,
  ) {
    final int aTotalLegs = a.stops.length - 1;
    final int aLegStops = ai - oi;
    final int aDurationRaw =
        aTotalLegs <= 0 ? a.runningTimeMin : (a.runningTimeMin * aLegStops / aTotalLegs).round();
    final int aDuration = aDurationRaw < 4 ? 4 : aDurationRaw;
    final int aFare = _fareFor(a.fare, aLegStops, aTotalLegs);

    final int bTotalLegs = b.stops.length - 1;
    final int bLegStops = dj - bi;
    final int bDurationRaw =
        bTotalLegs <= 0 ? b.runningTimeMin : (b.runningTimeMin * bLegStops / bTotalLegs).round();
    final int bDuration = bDurationRaw < 4 ? 4 : bDurationRaw;
    final int bFare = _fareFor(b.fare, bLegStops, bTotalLegs);

    const int walkDuration = 3;

    final List<TripLeg> legs = <TripLeg>[
      TripLeg(
        mode: TravelMode.bus,
        from: origin,
        to: mid,
        busNumber: a.number,
        durationMin: aDuration,
        fare: aFare,
        instruction: 'Board Bus ${a.number} at $origin and get off at $mid.',
      ),
      TripLeg(
        mode: TravelMode.walk,
        from: mid,
        to: mid,
        durationMin: walkDuration,
        fare: 0,
        instruction:
            'Change buses at $mid (about $walkDuration min walk to the Bus ${b.number} stop).',
      ),
      TripLeg(
        mode: TravelMode.bus,
        from: mid,
        to: destination,
        busNumber: b.number,
        durationMin: bDuration,
        fare: bFare,
        instruction: 'Board Bus ${b.number} at $mid and stay on till $destination.',
      ),
    ];

    return TripItinerary(
      originResolved: origin,
      destinationResolved: destination,
      legs: legs,
      totalDurationMin: aDuration + walkDuration + bDuration,
      totalFare: aFare + bFare,
      isEstimate: false,
    );
  }

  TripItinerary _rickshawFallback(String origin, String destination) {
    final String o = origin.isEmpty ? 'your location' : origin;
    final String d = destination.isEmpty ? 'that destination' : destination;
    return TripItinerary(
      originResolved: o,
      destinationResolved: d,
      legs: <TripLeg>[
        TripLeg(
          mode: TravelMode.rickshaw,
          from: o,
          to: d,
          durationMin: 18,
          fare: 70,
          instruction:
              'No MBMT bus route within one change is known between $o and $d in this prototype. '
              'An auto-rickshaw is suggested instead - this duration and fare are a rough estimate, '
              'not a live quote.',
        ),
      ],
      totalDurationMin: 18,
      totalFare: 70,
      isEstimate: true,
    );
  }
}
