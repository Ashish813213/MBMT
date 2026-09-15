import 'package:flutter_test/flutter_test.dart';

import 'package:mbmt_smart_bus/data/bus_stops.dart';
import 'package:mbmt_smart_bus/data/mock_data.dart';
import 'package:mbmt_smart_bus/data/real_routes.dart';
import 'package:mbmt_smart_bus/services/trip_planner.dart';

void main() {
  test('Collected stop table is intact', () {
    expect(kRealStops.length, 89);
    expect(kZoneStopNames.length, 73);
    // Every route halt resolves to coordinates (map never breaks).
    for (final bus in kRealBuses) {
      for (final stop in bus.stops) {
        expect(stopByName(stop), isNotNull,
            reason: 'Bus ${bus.number} references unknown stop "$stop"');
      }
    }
  });

  test('Legacy dummy numbers resolve to real routes', () {
    expect(MockData.busByNumber('45A').number, '29');
    expect(MockData.busByNumber('7').number, '14');
    expect(MockData.busByNumber('29AC').number, '29AC');
  });

  test('Trip planner finds a real bus to Thane', () {
    final itinerary = TripPlanner.instance
        .plan('Mira Road Station (E)', 'Thane Station (E) Kopri');
    expect(itinerary.isEstimate, isFalse);
    expect(itinerary.legs, isNotEmpty);
    expect(itinerary.legs.first.busNumber, '29');
  });

  test('Every collected stop is searchable by its buses', () {
    final kashimira = stopByName('Kashimira Junction');
    expect(kashimira, isNotNull);
    expect(kashimira!.buses, containsAll(<String>['5', '14', '25', '29']));
    expect(stopsForBus('15').length, greaterThanOrEqualTo(8));
  });

  test('Every halted bus number has a route (except external feeders)', () {
    // '11' is a BEST feeder at Dahisar Check Naka, not an MBMT route.
    const Set<String> external = <String>{'11'};
    final Set<String> referenced = <String>{
      for (final RealStop s in kRealStops) ...s.buses,
    };
    final Set<String> routes =
        kRealBuses.map((bus) => bus.number).toSet();
    expect(referenced.difference(routes).difference(external), isEmpty);
  });
}
