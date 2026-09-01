import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Enums + small helpers
/// ---------------------------------------------------------------------------

enum Crowd { low, medium, high }

extension CrowdX on Crowd {
  String get label {
    switch (this) {
      case Crowd.low:
        return 'Low Crowd';
      case Crowd.medium:
        return 'Medium Crowd';
      case Crowd.high:
        return 'High Crowd';
    }
  }

  /// Short label used on tight cards.
  String get shortLabel {
    switch (this) {
      case Crowd.low:
        return 'Low';
      case Crowd.medium:
        return 'Medium';
      case Crowd.high:
        return 'High';
    }
  }

  String get dot {
    switch (this) {
      case Crowd.low:
        return '\u{1F7E2}'; // green circle
      case Crowd.medium:
        return '\u{1F7E1}'; // yellow circle
      case Crowd.high:
        return '\u{1F534}'; // red circle
    }
  }
}

enum BusStatus { arriving, onTime, delayed }

extension BusStatusX on BusStatus {
  String get label {
    switch (this) {
      case BusStatus.arriving:
        return 'Arriving soon';
      case BusStatus.onTime:
        return 'On time';
      case BusStatus.delayed:
        return 'Delayed';
    }
  }
}

enum UpdateType { diversion, delay, cancellation, information }

extension UpdateTypeX on UpdateType {
  String get label {
    switch (this) {
      case UpdateType.diversion:
        return 'Diversion';
      case UpdateType.delay:
        return 'Delay';
      case UpdateType.cancellation:
        return 'Cancellation';
      case UpdateType.information:
        return 'Information';
    }
  }
}

enum UpdateSeverity { info, warning, critical }

/// ---------------------------------------------------------------------------
/// Data models
/// ---------------------------------------------------------------------------

class Bus {
  final String number;
  final String destination;
  final String via;
  final int etaMin;
  final int fare;
  final Crowd crowd;
  final BusStatus status;
  final String vehicleNo;
  final double distanceKm;
  final List<String> stops;
  final int nextStopIndex;

  // --- timetable ---------------------------------------------------------
  final int headwayMin; // roughly one bus every N minutes
  final String firstBus; // "05:40"
  final String lastBus; // "22:45"
  final String depot;
  final int runningTimeMin; // scheduled end-to-end running time

  const Bus({
    required this.number,
    required this.destination,
    required this.via,
    required this.etaMin,
    required this.fare,
    required this.crowd,
    required this.status,
    required this.vehicleNo,
    required this.distanceKm,
    required this.stops,
    required this.nextStopIndex,
    this.headwayMin = 12,
    this.firstBus = '05:45',
    this.lastBus = '22:45',
    this.depot = 'Mira Road Depot',
    this.runningTimeMin = 40,
  });

  String get nextStop =>
      nextStopIndex >= 0 && nextStopIndex < stops.length ? stops[nextStopIndex] : stops.last;

  String get origin => stops.isNotEmpty ? stops.first : '';

  String get frequencyLabel => 'Every $headwayMin min';

  String get serviceHoursLabel => '$firstBus - $lastBus';
}

/// A recommended route in the Journey Planner.
class RouteOption {
  final String id;
  final String tag; // 'fastest' | 'cheapest' | 'less-crowded'
  final String busNumber;
  final int durationMin;
  final int fare;
  final int arrivingInMin;
  final Crowd crowd;
  final String via;
  final int headwayMin;
  final String firstBus;
  final String lastBus;

  const RouteOption({
    required this.id,
    required this.tag,
    required this.busNumber,
    required this.durationMin,
    required this.fare,
    required this.arrivingInMin,
    required this.crowd,
    required this.via,
    this.headwayMin = 12,
    this.firstBus = '05:45',
    this.lastBus = '22:45',
  });

  String get tagLabel {
    switch (tag) {
      case 'fastest':
        return 'Fastest';
      case 'cheapest':
        return 'Cheapest';
      case 'less-crowded':
        return 'Less Crowded';
      default:
        return tag;
    }
  }
}

class ServiceUpdate {
  final String id;
  final UpdateType type;
  final String route;
  final String title;
  final String body;
  final String ago;
  final UpdateSeverity severity;

  const ServiceUpdate({
    required this.id,
    required this.type,
    required this.route,
    required this.title,
    required this.body,
    required this.ago,
    required this.severity,
  });
}

class FrequentJourney {
  final String id;
  final String from;
  final String to;
  final int nextBusMin;
  final String busNumber;

  const FrequentJourney({
    required this.id,
    required this.from,
    required this.to,
    required this.nextBusMin,
    required this.busNumber,
  });
}

class AppNotification {
  final String id;
  final IconData icon;
  final Color tint;
  final String title;
  final String body;
  final String ago;
  final bool read;

  const AppNotification({
    required this.id,
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
    required this.ago,
    this.read = false,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        icon: icon,
        tint: tint,
        title: title,
        body: body,
        ago: ago,
        read: read ?? this.read,
      );
}

class TransitPass {
  final String id;
  final String type;
  final int price;
  final String validity;
  final String status; // 'active' | 'available'
  final String zone;
  final String? purchased;

  const TransitPass({
    required this.id,
    required this.type,
    required this.price,
    required this.validity,
    required this.status,
    required this.zone,
    this.purchased,
  });
}

class Ticket {
  final String id;
  final String from;
  final String to;
  final String route;
  final int fare;
  final String date;
  final String time;
  final String status; // 'active' | 'completed' | 'expired'
  final String passengers;
  final String vehicleNo;

  const Ticket({
    required this.id,
    required this.from,
    required this.to,
    required this.route,
    required this.fare,
    required this.date,
    required this.time,
    required this.status,
    required this.passengers,
    required this.vehicleNo,
  });
}

class TicketDraft {
  final String from;
  final String to;
  final String date; // 'Today' | 'Tomorrow'
  final int count;
  final int fare;
  final String route;
  final String vehicleNo;

  const TicketDraft({
    required this.from,
    required this.to,
    this.date = 'Today',
    this.count = 1,
    this.fare = 25,
    this.route = '45A',
    this.vehicleNo = 'MH 04 LA 1234',
  });

  int get total => fare * count;

  TicketDraft copyWith({
    String? from,
    String? to,
    String? date,
    int? count,
    int? fare,
    String? route,
    String? vehicleNo,
  }) {
    return TicketDraft(
      from: from ?? this.from,
      to: to ?? this.to,
      date: date ?? this.date,
      count: count ?? this.count,
      fare: fare ?? this.fare,
      route: route ?? this.route,
      vehicleNo: vehicleNo ?? this.vehicleNo,
    );
  }
}

/// Result of a search-bar query.
enum SearchKind { destination, stop, bus, route }

class SearchResult {
  final String title;
  final String subtitle;
  final SearchKind kind;

  const SearchResult({
    required this.title,
    required this.subtitle,
    required this.kind,
  });
}
