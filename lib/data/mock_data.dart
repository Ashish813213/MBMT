import 'package:flutter/material.dart';

import '../models/models.dart';
import 'bus_stops.dart';
import 'real_routes.dart';

/// App content: real collected stop/route data (see `bus_stops.dart` and
/// `real_routes.dart`) plus presentation-only sample content (passes,
/// ticket history, notifications).
///
/// Place names and coordinates come from 52 unique OSM `highway=bus_stop`
/// nodes merged with the official MBMC route network (86 in-zone stops +
/// Outside-MBMC termini). Timetable values are the MBMC portal's published
/// first/last trips; ETAs, crowd levels and fares are realistic samples for
/// a project presentation - not a live schedule.
class MockData {
  MockData._();

  /// Header location picker.
  static const List<String> locations = <String>[
    'Mira Road (E), Thane',
    'Mira Road (W), Thane',
    'Bhayandar (E)',
    'Bhayandar (W)',
    'Kashimira',
    'Ghodbunder Road',
    'Uttan',
  ];

  /// Master list of MBMT stops / stations across the network. Used by the
  /// search index and the From / To pickers. Backed by the collected
  /// `kRealStops` table (includes Outside-MBMC termini so Thane / Andheri /
  /// Borivali routes resolve; UI filters them behind an opt-in toggle).
  static List<String> get stops => kAllStopNames;

  /// Stops inside the MBMC zone (Outside-MBMC termini excluded). Used by
  /// search and pickers by default.
  static List<String> get zoneStops => kZoneStopNames;

  static List<Bus> get nearbyBuses => kRealBuses;

  static int fareForRoute(String routeNumber) {
    try {
      return kRealBuses
          .firstWhere(
              (Bus b) => b.number.toLowerCase() == routeNumber.toLowerCase())
          .fare;
    } catch (_) {
      return 25;
    }
  }

  static String busNumberForStops(String from, String to) {
    for (final Bus b in kRealBuses) {
      final int fromIndex = _stopIndex(b.stops, from);
      final int toIndex = _stopIndex(b.stops, to);
      if (fromIndex >= 0 && toIndex > fromIndex) {
        return b.number;
      }
    }
    return kRealBuses.first.number;
  }

  /// Returns only buses whose published stop sequence actually travels from
  /// [from] to [to] in that order. This keeps the planner and tracking screen
  /// on the same real route instead of showing presentation-only suggestions.
  static List<RouteOption> routeOptionsFor(String from, String to) {
    final List<_RouteMatch> matches = <_RouteMatch>[];
    for (final Bus bus in kRealBuses) {
      final int fromIndex = _stopIndex(bus.stops, from);
      final int toIndex = _stopIndex(bus.stops, to);
      if (fromIndex < 0 || toIndex <= fromIndex) continue;

      final int legs = toIndex - fromIndex;
      final int routeLegs = bus.stops.length > 1 ? bus.stops.length - 1 : 1;
      final int estimatedDuration =
          (bus.runningTimeMin * legs / routeLegs).round();
      final int estimatedFare = (bus.fare * legs / routeLegs).round();
      matches.add(_RouteMatch(
        bus: bus,
        durationMin: estimatedDuration < 3 ? 3 : estimatedDuration,
        fare: estimatedFare < 10 ? 10 : estimatedFare,
      ));
    }

    matches.sort((a, b) => a.durationMin.compareTo(b.durationMin));
    final List<_RouteMatch> distinct = <_RouteMatch>[];
    final Set<String> numbers = <String>{};
    for (final _RouteMatch match in matches) {
      if (numbers.add(match.bus.number)) distinct.add(match);
    }

    final List<_RouteMatch> cheapest = List<_RouteMatch>.from(distinct)
      ..sort((a, b) => a.fare.compareTo(b.fare));
    final List<_RouteMatch> leastCrowded = List<_RouteMatch>.from(distinct)
      ..sort((a, b) => _crowdRank(a.bus.crowd).compareTo(_crowdRank(b.bus.crowd)));

    return distinct.take(3).map((_RouteMatch match) {
      String tag = 'recommended';
      if (match.bus.number == distinct.first.bus.number) {
        tag = 'fastest';
      } else if (cheapest.isNotEmpty && match.bus.number == cheapest.first.bus.number) {
        tag = 'cheapest';
      } else if (leastCrowded.isNotEmpty && match.bus.number == leastCrowded.first.bus.number) {
        tag = 'less-crowded';
      }
      return RouteOption(
        id: 'real-${match.bus.number}-${_stopIndex(match.bus.stops, from)}-${_stopIndex(match.bus.stops, to)}',
        tag: tag,
        busNumber: match.bus.number,
        durationMin: match.durationMin,
        fare: match.fare,
        arrivingInMin: match.bus.etaMin,
        crowd: match.bus.crowd,
        via: match.bus.via,
        headwayMin: match.bus.headwayMin,
        firstBus: match.bus.firstBus,
        lastBus: match.bus.lastBus,
      );
    }).toList();
  }

  static int _stopIndex(List<String> stops, String requested) {
    final String q = requested.trim().toLowerCase();
    return stops.indexWhere((String stop) => stop.trim().toLowerCase() == q);
  }

  static int _crowdRank(Crowd crowd) {
    switch (crowd) {
      case Crowd.low:
        return 0;
      case Crowd.medium:
        return 1;
      case Crowd.high:
        return 2;
    }
  }

  /// Resolves a route number to its [Bus], following legacy dummy aliases
  /// (`45A` -> `29`, `7` -> `14`) so old favourites and links keep working.
  static Bus busByNumber(String number) {
    final String q = number.trim().toLowerCase();
    final String resolved = kLegacyBusAliases[q.toUpperCase()] ?? number;
    final String rq = resolved.toLowerCase();
    return kRealBuses.firstWhere(
      (Bus b) => b.number.toLowerCase() == rq,
      orElse: () => kRealBuses.firstWhere(
        (Bus b) => b.number.toLowerCase() == q,
        orElse: () => kRealBuses.first,
      ),
    );
  }

  /// Journey Planner recommendations for Mira Road Station (E) ->
  /// Thane Station (E) Kopri.
  static const List<RouteOption> routeOptions = <RouteOption>[
    RouteOption(
      id: 'r-29',
      tag: 'fastest',
      busNumber: '29',
      durationMin: 52,
      fare: 30,
      arrivingInMin: 6,
      crowd: Crowd.medium,
      via: 'Kashimira & S.K. Stone',
      headwayMin: 12,
      firstBus: '05:45',
      lastBus: '20:15',
    ),
    RouteOption(
      id: 'r-10',
      tag: 'cheapest',
      busNumber: '10',
      durationMin: 70,
      fare: 25,
      arrivingInMin: 12,
      crowd: Crowd.high,
      via: 'Bhayandar & Ghodbunder Road',
      headwayMin: 15,
      firstBus: '05:45',
      lastBus: '19:30',
    ),
    RouteOption(
      id: 'r-29AC',
      tag: 'less-crowded',
      busNumber: '29AC',
      durationMin: 48,
      fare: 50,
      arrivingInMin: 8,
      crowd: Crowd.low,
      via: 'Kashimira (AC Express)',
      headwayMin: 35,
      firstBus: '07:25',
      lastBus: '18:55',
    ),
  ];

  static const List<ServiceUpdate> serviceUpdates = <ServiceUpdate>[
    ServiceUpdate(
      id: 'su1',
      type: UpdateType.diversion,
      route: 'Route 29',
      title: 'Route 29 diversion near S.K. Stone',
      body:
          'Diversion near S.K. Stone on Mira-Ghodbunder Road due to traffic. Buses run via '
          'Kashigaon and rejoin the route at Kashimira Junction.',
      ago: '10 min ago',
      severity: UpdateSeverity.warning,
    ),
    ServiceUpdate(
      id: 'su2',
      type: UpdateType.delay,
      route: 'Route 12',
      title: 'Route 12 running late',
      body:
          'Delay of 15-20 minutes between Bhayandar Station and Golden Nest Circle due to road '
          'repair work near Ghoddev Naka.',
      ago: '25 min ago',
      severity: UpdateSeverity.warning,
    ),
    ServiceUpdate(
      id: 'su3',
      type: UpdateType.information,
      route: 'Route 1',
      title: 'Extra buses to Uttan on Sundays',
      body:
          'Additional buses on Route 1 (Bhayandar Station (W) - Uttan) every Sunday between '
          '07:00 and 11:00 for Uttan beach.',
      ago: '1 hr ago',
      severity: UpdateSeverity.info,
    ),
    ServiceUpdate(
      id: 'su4',
      type: UpdateType.cancellation,
      route: 'Route 14',
      title: 'Late-night trip cancelled today',
      body:
          'The 20:00 trip on Route 14 from Bhayandar Station (E) to Borivali National Park is '
          'cancelled today for scheduled vehicle maintenance.',
      ago: '2 hr ago',
      severity: UpdateSeverity.critical,
    ),
    ServiceUpdate(
      id: 'su5',
      type: UpdateType.information,
      route: 'All routes',
      title: 'QR digital tickets now accepted',
      body: 'All MBMT conductors now accept QR digital tickets shown from the MBMT app.',
      ago: '1 day ago',
      severity: UpdateSeverity.info,
    ),
  ];

  static const List<FrequentJourney> frequentJourneys = <FrequentJourney>[
    FrequentJourney(
      id: 'fj1',
      from: 'Mira Road Station (E)',
      to: 'Thane Station (E) Kopri',
      nextBusMin: 8,
      busNumber: '29',
    ),
    FrequentJourney(
      id: 'fj2',
      from: 'Mira Road Station (E)',
      to: 'Bhayandar Station (E)',
      nextBusMin: 13,
      busNumber: '26',
    ),
  ];

  static const List<String> recentSearches = <String>[
    'Kashimira Junction',
    'Bhayandar Station (E)',
    '29'
  ];

  static const List<SearchResult> suggestedDestinations = <SearchResult>[
    SearchResult(title: 'Thane Station (E) Kopri', subtitle: 'Railway station - via Kashimira & S.K. Stone', kind: SearchKind.destination),
    SearchResult(title: 'Bhayandar Station (E)', subtitle: 'Railway station - 5 km', kind: SearchKind.destination),
    SearchResult(title: 'Mira Road Station (W)', subtitle: 'Railway station - 2 km', kind: SearchKind.destination),
    SearchResult(title: 'Golden Nest Circle', subtitle: 'Junction - Bhayandar East', kind: SearchKind.stop),
    SearchResult(title: 'Dahisar Check Naka', subtitle: 'Highway stop - Mumbai border', kind: SearchKind.stop),
    SearchResult(title: 'Maxus Mall', subtitle: 'Landmark - Bhayandar West', kind: SearchKind.destination),
    SearchResult(title: 'Uttan Naka', subtitle: 'Coastal terminus - Routes 2, 6', kind: SearchKind.destination),
    SearchResult(title: 'Kashimira Junction', subtitle: 'Junction - Routes 5, 14, 25, 29', kind: SearchKind.stop),
  ];

  static const List<TransitPass> passes = <TransitPass>[
    TransitPass(
      id: 'p1',
      type: 'Daily Pass',
      price: 60,
      validity: 'Valid till 11:59 PM today',
      status: 'active',
      zone: 'All MBMT routes (Mira-Bhayandar)',
      purchased: 'Today, 7:10 AM',
    ),
    TransitPass(
      id: 'p2',
      type: 'Weekly Pass',
      price: 300,
      validity: 'Expires in 4 days',
      status: 'active',
      zone: 'All MBMT routes (Mira-Bhayandar)',
      purchased: '27 Aug 2026',
    ),
    TransitPass(
      id: 'p3',
      type: 'Monthly Pass',
      price: 1000,
      validity: 'Unlimited travel for 30 days',
      status: 'available',
      zone: 'All MBMT routes (Mira-Bhayandar)',
    ),
    TransitPass(
      id: 'p4',
      type: 'Student Monthly',
      price: 450,
      validity: 'Requires a valid student ID',
      status: 'available',
      zone: 'All MBMT routes (Mira-Bhayandar)',
    ),
  ];

  static const List<Ticket> ticketHistory = <Ticket>[
    Ticket(
      id: 'TKT230815421',
      from: 'Mira Road Station (E)',
      to: 'Bhayandar Station (E)',
      route: '12',
      fare: 22,
      date: '28 Aug 2026',
      time: '6:40 PM',
      status: 'completed',
      passengers: '1 Adult',
      vehicleNo: 'MH 04 JB 4521',
    ),
    Ticket(
      id: 'TKT230788110',
      from: 'Bhayandar Station (W)',
      to: 'Rai Morva / Morva Bhat',
      route: '20',
      fare: 20,
      date: '27 Aug 2026',
      time: '9:05 AM',
      status: 'completed',
      passengers: '1 Adult',
      vehicleNo: 'MH 04 KT 8890',
    ),
    Ticket(
      id: 'TKT230744902',
      from: 'Mira Road Station (E)',
      to: 'Thane Station (E) Kopri',
      route: '29',
      fare: 30,
      date: '24 Aug 2026',
      time: '10:15 AM',
      status: 'completed',
      passengers: '2 Adult',
      vehicleNo: 'MH 04 LA 1234',
    ),
    Ticket(
      id: 'TKT230701255',
      from: 'Kashimira Junction',
      to: 'Thane Station (E) Kopri',
      route: '29',
      fare: 30,
      date: '21 Aug 2026',
      time: '8:30 AM',
      status: 'expired',
      passengers: '1 Adult',
      vehicleNo: 'MH 04 LA 1234',
    ),
  ];

  static List<AppNotification> notifications() => <AppNotification>[
        const AppNotification(
          id: 'n1',
          icon: Icons.warning_amber_rounded,
          tint: Color(0xFFF97316),
          title: 'Route 29 diversion',
          body: 'Diversion near S.K. Stone on Mira-Ghodbunder Road due to traffic.',
          ago: '10 min ago',
        ),
        const AppNotification(
          id: 'n2',
          icon: Icons.directions_bus_rounded,
          tint: Color(0xFF0B8F55),
          title: 'Bus 29 arriving soon',
          body: 'Your bus to Thane Station (E) Kopri is about 6 min from Mira Road Station (E).',
          ago: '12 min ago',
        ),
        const AppNotification(
          id: 'n3',
          icon: Icons.confirmation_number_rounded,
          tint: Color(0xFF1A4FBD),
          title: 'Daily pass expiring',
          body: 'Your daily pass expires at 11:59 PM today.',
          ago: '1 hr ago',
        ),
        const AppNotification(
          id: 'n4',
          icon: Icons.info_rounded,
          tint: Color(0xFF1A4FBD),
          title: 'Welcome to MBMT Smart Bus',
          body: 'Your account is ready. Plan your first journey!',
          ago: '2 days ago',
          read: true,
        ),
      ];

  static const List<String> languages = <String>['English', 'हिन्दी', 'मराठी'];

  static const Map<String, String> languageCodes = <String, String>{
    'English': 'en',
    'हिन्दी': 'hi',
    'मराठी': 'mr',
  };
}

class _RouteMatch {
  const _RouteMatch({
    required this.bus,
    required this.durationMin,
    required this.fare,
  });

  final Bus bus;
  final int durationMin;
  final int fare;
}
