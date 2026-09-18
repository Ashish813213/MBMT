import 'dart:math';

/// Straight-line (great-circle) distance between two GPS coordinates, in
/// kilometres. Shared by [TripPlanner]'s no-bus-route fallback and the Home
/// screen's real-GPS "Buses Near You" so both use the same distance math.
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const double earthRadiusKm = 6371.0;
  final double dLat = _degToRad(lat2 - lat1);
  final double dLng = _degToRad(lng2 - lng1);
  final double a = _degToRad(lat1);
  final double b = _degToRad(lat2);
  final double h = sin(dLat / 2) * sin(dLat / 2) + cos(a) * cos(b) * sin(dLng / 2) * sin(dLng / 2);
  return earthRadiusKm * 2 * atan2(sqrt(h), sqrt(1 - h));
}

double _degToRad(double deg) => deg * (pi / 180.0);
