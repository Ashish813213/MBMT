import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/bus_card.dart';

class TrackBusScreen extends StatefulWidget {
  const TrackBusScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<TrackBusScreen> createState() => _TrackBusScreenState();
}

class _TrackBusScreenState extends State<TrackBusScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final String q = _q.trim().toLowerCase();
    final List<Bus> buses = q.isEmpty
        ? MockData.nearbyBuses
        : MockData.nearbyBuses
            .where((Bus b) =>
                b.number.toLowerCase().contains(q) ||
                b.destination.toLowerCase().contains(q) ||
                b.via.toLowerCase().contains(q))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Track a Bus'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              onChanged: (String v) => setState(() => _q = v),
              decoration: const InputDecoration(
                hintText: 'Search bus number or destination',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: buses.isEmpty
                ? const Center(
                    child: Text('No buses match your search',
                        style: TextStyle(color: AppColors.inkSoft)),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    children: <Widget>[
                      const Row(
                        children: <Widget>[
                          Icon(Icons.my_location_rounded, size: 15, color: AppColors.brand),
                          SizedBox(width: 6),
                          Text('Live buses near you',
                              style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...buses.map((Bus b) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: BusCard(bus: b, showStatus: true),
                          )),
                      const SizedBox(height: 6),
                      Center(
                        child: Text('Tap a bus to follow it live on the map',
                            style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
