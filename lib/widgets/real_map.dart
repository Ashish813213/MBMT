import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/bus_stops.dart';
import '../theme/app_theme.dart';

/// Real Leaflet-based map (OpenStreetMap tiles) for live bus tracking.
///
/// Draws the route polyline through the real collected stop coordinates,
/// a dot per halt and an animated bus marker at [progress] (0..1 along the
/// route). Stop order along each route is geographic (depot-outbound) and
/// therefore estimated - the caption under the map says so.
///
/// Requires internet for tiles (already declared in AndroidManifest).
/// If tiles fail to load, the route line and markers still render over the
/// plain background, so the screen never goes blank.
class RealMap extends StatelessWidget {
  const RealMap({
    super.key,
    required this.stops,
    required this.progress,
    required this.userIndex,
    this.height = 260,
  });

  /// Ordered halts of the tracked route (resolved from `kRealStops`).
  final List<RealStop> stops;

  /// 0..1 along the route.
  final double progress;
  final int userIndex;
  final double height;

  List<LatLng> get _points =>
      stops.map((RealStop s) => LatLng(s.lat, s.lng)).toList();

  LatLng _centre() {
    final List<LatLng> pts = _points;
    if (pts.isEmpty) return LatLng(19.29, 72.85);
    double lat = 0, lng = 0;
    for (final LatLng p in pts) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / pts.length, lng / pts.length);
  }

  /// Interpolated bus position along the polyline at [progress].
  LatLng _busAt(List<LatLng> pts, double t) {
    if (pts.isEmpty) return LatLng(19.29, 72.85);
    if (pts.length == 1) return pts.first;
    const Distance dist = Distance();
    final List<double> segs = <double>[
      for (int i = 0; i < pts.length - 1; i++) dist(pts[i], pts[i + 1]),
    ];
    final double total = segs.fold(0.0, (double a, double b) => a + b);
    if (total <= 0) return pts.first;
    double target = (t.clamp(0.0, 1.0)) * total;
    for (int i = 0; i < segs.length; i++) {
      if (target <= segs[i] || i == segs.length - 1) {
        final double f = segs[i] <= 0 ? 0 : (target / segs[i]).clamp(0.0, 1.0);
        return LatLng(
          pts[i].latitude + (pts[i + 1].latitude - pts[i].latitude) * f,
          pts[i].longitude + (pts[i + 1].longitude - pts[i].longitude) * f,
        );
      }
      target -= segs[i];
    }
    return pts.last;
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> pts = _points;
    final LatLng busPos = _busAt(pts, progress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _centre(),
                    initialZoom: 12,
                    interactionOptions:
                        const InteractionOptions(flags: InteractiveFlag.all),
                  ),
                  children: <Widget>[
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.mbmt.smart_bus',
                      maxZoom: 19,
                    ),
                    if (pts.length > 1)
                      PolylineLayer(
                        polylines: <Polyline>[
                          Polyline(
                            points: pts,
                            color: AppColors.brand,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: <Marker>[
                        for (int i = 0; i < stops.length; i++)
                          Marker(
                            point: pts[i],
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                color: i == stops.length - 1
                                    ? AppColors.danger
                                    : AppColors.brand,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2.5),
                              ),
                              child: i == userIndex
                                  ? const Icon(Icons.person_rounded,
                                      size: 13, color: Colors.white)
                                  : null,
                            ),
                          ),
                        Marker(
                          point: busPos,
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.live, width: 3),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(
                                Icons.directions_bus_rounded,
                                size: 20,
                                color: AppColors.live),
                          ),
                        ),
                      ],
                    ),
                    const SimpleAttributionWidget(
                      source: Text('© OpenStreetMap contributors'),
                    ),
                  ],
                ),
                Positioned(
                  right: 10,
                  bottom: 28,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.trip_origin_rounded,
                            size: 11, color: AppColors.live),
                        SizedBox(width: 4),
                        Text('Live',
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Live map · OSM tiles need internet · route path is estimated from collected stop GPS',
          style: TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}
