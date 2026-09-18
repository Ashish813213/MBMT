/// A "leave now" reminder for a regular bus - distinct from the live
/// tracking screen's [TravelAlert] (which fires while riding, close to your
/// stop). This one fires [leadMinutes] before a daily boarding time, so you
/// don't miss the bus before you've even left. Checked in-app on a timer
/// while the app is running (see `AppState.startReminderClock`) rather than
/// as an OS push notification - persisted so the reminder itself survives a
/// restart even though the alert only fires while the app is open.
class DepartureReminder {
  final String id;
  final String busNumber;
  final String stopName;
  final int hour;
  final int minute;
  final int leadMinutes;
  final bool enabled;

  const DepartureReminder({
    required this.id,
    required this.busNumber,
    required this.stopName,
    required this.hour,
    required this.minute,
    required this.leadMinutes,
    this.enabled = true,
  });

  String get timeLabel {
    final int h12 = hour % 12 == 0 ? 12 : hour % 12;
    final String mm = minute.toString().padLeft(2, '0');
    final String ap = hour < 12 ? 'AM' : 'PM';
    return '$h12:$mm $ap';
  }

  DepartureReminder copyWith({
    String? busNumber,
    String? stopName,
    int? hour,
    int? minute,
    int? leadMinutes,
    bool? enabled,
  }) {
    return DepartureReminder(
      id: id,
      busNumber: busNumber ?? this.busNumber,
      stopName: stopName ?? this.stopName,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      leadMinutes: leadMinutes ?? this.leadMinutes,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'bus_number': busNumber,
        'stop_name': stopName,
        'hour': hour,
        'minute': minute,
        'lead_minutes': leadMinutes,
        'enabled': enabled,
      };

  factory DepartureReminder.fromJson(Map<String, dynamic> json) => DepartureReminder(
        id: json['id'] as String,
        busNumber: json['bus_number'] as String,
        stopName: json['stop_name'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        leadMinutes: json['lead_minutes'] as int,
        enabled: json['enabled'] as bool? ?? true,
      );
}
