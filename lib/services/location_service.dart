import 'package:geolocator/geolocator.dart';

/// The outcome of a location lookup. Either [latitude]/[longitude] are set,
/// or [error] explains why not (permission, disabled service, timeout).
class LocationResult {
  final double? latitude;
  final double? longitude;
  final String? error;

  const LocationResult({this.latitude, this.longitude, this.error});

  bool get hasCoordinates => latitude != null && longitude != null;
}

/// Thin wrapper around `geolocator` - used by the SOS screen (a message is
/// only useful with a real location) and the Home screen's "Buses Near You"
/// (to show buses that actually serve the nearest real stop). Every other
/// screen in this prototype uses the app's simulated [AppState.location]
/// string instead.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<LocationResult> getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          error: 'Location services are turned off on this device.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult(error: 'Location permission was denied.');
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          error: 'Location permission is permanently denied. Enable it from app settings.',
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 15));

      return LocationResult(latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      return LocationResult(error: 'Could not get your location right now.');
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
