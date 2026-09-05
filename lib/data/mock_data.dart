import 'package:flutter/material.dart';

import '../models/models.dart';

/// Demo content for the MBMT Smart Bus prototype.
///
/// Place names, stations and corridors below are the *real* Mira-Bhayandar /
/// Ghodbunder Road / Thane geography that MBMT serves. Route numbers, ETAs,
/// fares, crowd levels and timetables are realistic sample values for a
/// project presentation - this is a *proposed redesigned* MBMT app and none of
/// the data reflects a live schedule.
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
  /// search index and the From / To pickers.
  static const List<String> stops = <String>[
    // Mira Road
    'Mira Road Station (E)',
    'Mira Road Station (W)',
    'Shanti Nagar (Mira Road)',
    'Silver Park',
    'Sheetal Nagar',
    'Hatkesh',
    'Kanakia',
    'Sai Baba Nagar',
    'Naya Nagar',
    'Ramdev Park',
    'Poonam Sagar',
    'Beverly Park',
    // Kashimira / highway
    'Kashimira Junction',
    'Kashigaon',
    'Dahisar Check Naka',
    'Dahisar Station (E)',
    // Bhayandar
    'Bhayandar Station (E)',
    'Bhayandar Station (W)',
    'Jesal Park',
    '150 Feet Road',
    'Golden Nest Circle',
    'Maxus Mall',
    'Navghar Road',
    'Indralok',
    'Rai Morva',
    'Chowk',
    'Dongri',
    'Uttan',
    'Pali Beach',
    'Maghatane',
    // Ghodbunder Road -> Thane
    'Ghodbunder Road',
    'Anand Nagar (Ghodbunder)',
    'Waghbil',
    'Hiranandani Estate',
    'Patlipada',
    'Manpada',
    'Kapurbawdi Junction',
    'Teen Haath Naka',
    'Thane Station',
  ];

  static const List<Bus> nearbyBuses = <Bus>[
    Bus(
      number: '45A',
      destination: 'Thane Station',
      via: 'Ghodbunder Road',
      etaMin: 6,
      fare: 25,
      crowd: Crowd.medium,
      status: BusStatus.arriving,
      vehicleNo: 'MH 04 LA 1234',
      distanceKm: 2.1,
      stops: <String>[
        'Mira Road Station (E)',
        'Kashimira Junction',
        'Ghodbunder Road',
        'Patlipada',
        'Thane Station',
      ],
      nextStopIndex: 1,
      headwayMin: 12,
      firstBus: '05:40',
      lastBus: '22:45',
      depot: 'Mira Road Depot',
      runningTimeMin: 38,
    ),
    Bus(
      number: '20',
      destination: 'Mira Road Station (E)',
      via: 'Bhayandar',
      etaMin: 11,
      fare: 20,
      crowd: Crowd.low,
      status: BusStatus.onTime,
      vehicleNo: 'MH 04 KT 8890',
      distanceKm: 3.4,
      stops: <String>[
        'Bhayandar Station (E)',
        'Jesal Park',
        '150 Feet Road',
        'Shanti Nagar (Mira Road)',
        'Mira Road Station (E)',
      ],
      nextStopIndex: 1,
      headwayMin: 10,
      firstBus: '05:30',
      lastBus: '23:15',
      depot: 'Bhayandar Depot',
      runningTimeMin: 26,
    ),
    Bus(
      number: '12',
      destination: 'Bhayandar Station (E)',
      via: 'Kanakia',
      etaMin: 18,
      fare: 22,
      crowd: Crowd.medium,
      status: BusStatus.onTime,
      vehicleNo: 'MH 04 JB 4521',
      distanceKm: 5.0,
      stops: <String>[
        'Mira Road Station (E)',
        'Sheetal Nagar',
        'Kanakia',
        'Silver Park',
        'Golden Nest Circle',
        'Bhayandar Station (E)',
      ],
      nextStopIndex: 2,
      headwayMin: 15,
      firstBus: '06:00',
      lastBus: '22:30',
      depot: 'Mira Road Depot',
      runningTimeMin: 34,
    ),
    Bus(
      number: '1',
      destination: 'Uttan',
      via: 'Chowk',
      etaMin: 24,
      fare: 18,
      crowd: Crowd.high,
      status: BusStatus.delayed,
      vehicleNo: 'MH 04 GF 2276',
      distanceKm: 6.7,
      stops: <String>[
        'Bhayandar Station (W)',
        'Maxus Mall',
        'Rai Morva',
        'Chowk',
        'Dongri',
        'Uttan',
      ],
      nextStopIndex: 1,
      headwayMin: 20,
      firstBus: '06:15',
      lastBus: '21:40',
      depot: 'Uttan Depot',
      runningTimeMin: 32,
    ),
    Bus(
      number: '6',
      destination: 'Bhayandar Station (E)',
      via: '150 Feet Road',
      etaMin: 9,
      fare: 15,
      crowd: Crowd.medium,
      status: BusStatus.onTime,
      vehicleNo: 'MH 04 CT 3390',
      distanceKm: 1.6,
      stops: <String>[
        'Mira Road Station (E)',
        'Hatkesh',
        'Kanakia',
        'Kashigaon',
        'Golden Nest Circle',
        '150 Feet Road',
        'Jesal Park',
        'Bhayandar Station (E)',
      ],
      nextStopIndex: 2,
      headwayMin: 8,
      firstBus: '05:20',
      lastBus: '23:30',
      depot: 'Mira Road Depot',
      runningTimeMin: 30,
    ),
    Bus(
      number: '7',
      destination: 'Dahisar Check Naka',
      via: 'Kashimira',
      etaMin: 14,
      fare: 15,
      crowd: Crowd.low,
      status: BusStatus.onTime,
      vehicleNo: 'MH 04 DL 7712',
      distanceKm: 4.2,
      stops: <String>[
        'Mira Road Station (E)',
        'Sai Baba Nagar',
        'Kanakia',
        'Kashimira Junction',
        'Dahisar Check Naka',
      ],
      nextStopIndex: 1,
      headwayMin: 12,
      firstBus: '05:45',
      lastBus: '23:00',
      depot: 'Mira Road Depot',
      runningTimeMin: 22,
    ),
  ];

  static int fareForRoute(String routeNumber) {
    try {
      return nearbyBuses.firstWhere((Bus b) => b.number == routeNumber).fare;
    } catch (_) {
      return 25;
    }
  }

  static String busNumberForStops(String from, String to) {
    for (final Bus b in nearbyBuses) {
      if (b.stops.contains(from) && b.stops.contains(to)) {
        return b.number;
      }
    }
    return nearbyBuses.first.number;
  }

  static Bus busByNumber(String number) {
    return nearbyBuses.firstWhere(
      (Bus b) => b.number.toLowerCase() == number.toLowerCase(),
      orElse: () => nearbyBuses.first,
    );
  }

  /// Journey Planner recommendations for Mira Road Station (E) -> Thane Station.
  static const List<RouteOption> routeOptions = <RouteOption>[
    RouteOption(
      id: 'r-45A',
      tag: 'fastest',
      busNumber: '45A',
      durationMin: 38,
      fare: 25,
      arrivingInMin: 6,
      crowd: Crowd.medium,
      via: 'Ghodbunder Road',
      headwayMin: 12,
      firstBus: '05:40',
      lastBus: '22:45',
    ),
    RouteOption(
      id: 'r-20',
      tag: 'cheapest',
      busNumber: '20',
      durationMin: 45,
      fare: 20,
      arrivingInMin: 11,
      crowd: Crowd.low,
      via: 'Bhayandar & 150 Feet Road',
      headwayMin: 10,
      firstBus: '05:30',
      lastBus: '23:15',
    ),
    RouteOption(
      id: 'r-12',
      tag: 'less-crowded',
      busNumber: '12',
      durationMin: 42,
      fare: 22,
      arrivingInMin: 18,
      crowd: Crowd.low,
      via: 'Kanakia & Golden Nest',
      headwayMin: 15,
      firstBus: '06:00',
      lastBus: '22:30',
    ),
  ];

  static const List<ServiceUpdate> serviceUpdates = <ServiceUpdate>[
    ServiceUpdate(
      id: 'su1',
      type: UpdateType.diversion,
      route: 'Route 45A',
      title: 'Route 45A diversion near Ghodbunder Road',
      body:
          'Diversion near Anand Nagar on Ghodbunder Road due to traffic. Buses run via '
          'Kashigaon and rejoin the route at Kashimira Junction.',
      ago: '10 min ago',
      severity: UpdateSeverity.warning,
    ),
    ServiceUpdate(
      id: 'su2',
      type: UpdateType.delay,
      route: 'Route 20',
      title: 'Route 20 running late',
      body:
          'Delay of 15-20 minutes between Bhayandar Station and 150 Feet Road due to road '
          'repair work near Jesal Park.',
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
      route: 'Route 7',
      title: 'Late-night trip cancelled today',
      body:
          'The 22:00 trip on Route 7 from Mira Road Station (E) to Dahisar Check Naka is '
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
       to: 'Thane Station',
       nextBusMin: 8,
       busNumber: '45A',
     ),
     FrequentJourney(
       id: 'fj2',
       from: 'Mira Road Station (E)',
       to: 'Bhayandar Station (E)',
       nextBusMin: 13,
       busNumber: '20',
     ),
   ];

  static const List<String> recentSearches = <String>['Thane Station', 'Bhayandar Station (E)', '45A'];

  static const List<SearchResult> suggestedDestinations = <SearchResult>[
    SearchResult(title: 'Thane Station', subtitle: 'Railway station - via Ghodbunder Road', kind: SearchKind.destination),
    SearchResult(title: 'Bhayandar Station (E)', subtitle: 'Railway station - 5 km', kind: SearchKind.destination),
    SearchResult(title: 'Mira Road Station (W)', subtitle: 'Railway station - 2 km', kind: SearchKind.destination),
    SearchResult(title: 'Golden Nest Circle', subtitle: 'Junction - Bhayandar East', kind: SearchKind.stop),
    SearchResult(title: 'Dahisar Check Naka', subtitle: 'Highway stop - Mumbai border', kind: SearchKind.stop),
    SearchResult(title: 'Maxus Mall', subtitle: 'Landmark - Bhayandar West', kind: SearchKind.destination),
    SearchResult(title: 'Uttan', subtitle: 'Coastal terminus - Route 1', kind: SearchKind.destination),
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
      from: 'Bhayandar Station (E)',
      to: 'Mira Road Station (E)',
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
      to: 'Thane Station',
      route: '45A',
      fare: 25,
      date: '24 Aug 2026',
      time: '10:15 AM',
      status: 'completed',
      passengers: '2 Adult',
      vehicleNo: 'MH 04 LA 1234',
    ),
    Ticket(
      id: 'TKT230701255',
      from: 'Kashimira Junction',
      to: 'Thane Station',
      route: '45A',
      fare: 20,
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
          title: 'Route 45A diversion',
          body: 'Diversion near Ghodbunder Road (Anand Nagar) due to traffic.',
          ago: '10 min ago',
        ),
        const AppNotification(
          id: 'n2',
          icon: Icons.directions_bus_rounded,
          tint: Color(0xFF0B8F55),
          title: 'Bus 45A arriving soon',
          body: 'Your bus to Thane Station is about 6 min from Mira Road Station (E).',
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
