/// A "wake me up" proximity alert for the live tracking screen: fires once
/// the tracked bus is within [stopsBefore] stops of [targetStopName].
class TravelAlert {
  final String targetStopName;
  final int stopsBefore;
  final bool vibrate;
  final bool sound;

  const TravelAlert({
    required this.targetStopName,
    required this.stopsBefore,
    this.vibrate = true,
    this.sound = true,
  });
}
