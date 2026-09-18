import 'dart:async';

import 'package:flutter/material.dart';

import '../data/bus_stops.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../services/geo_utils.dart';
import '../services/location_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_header.dart';
import '../widgets/bus_card.dart';
import '../widgets/common.dart';
import '../widgets/journey_card.dart';
import '../widgets/quick_action.dart';
import '../widgets/search_bar.dart';
import '../widgets/service_update_card.dart';
import 'ai_assistant_screen.dart';
import 'buy_ticket_screen.dart';
import 'favourites_screen.dart';
import 'service_updates_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Bus> _nearbyBuses = MockData.nearbyBuses.take(3).toList();
  String? _nearestStopLabel;

  @override
  void initState() {
    super.initState();
    unawaited(_loadNearbyByRealLocation());
  }

  /// Tries to replace the sample "Buses Near You" list with buses that
  /// actually serve the stop(s) nearest the device's real GPS position -
  /// falls back to (and leaves untouched) the sample list above on any
  /// permission/GPS failure, exactly like the SOS screen's location handling.
  Future<void> _loadNearbyByRealLocation() async {
    final LocationResult loc = await LocationService.instance.getCurrentLocation();
    if (!mounted || !loc.hasCoordinates || kRealStops.isEmpty) return;

    final List<RealStop> byDistance = List<RealStop>.from(kRealStops)
      ..sort((RealStop a, RealStop b) => haversineKm(loc.latitude!, loc.longitude!, a.lat, a.lng)
          .compareTo(haversineKm(loc.latitude!, loc.longitude!, b.lat, b.lng)));

    final RealStop nearest = byDistance.first;
    final double distanceKm = haversineKm(loc.latitude!, loc.longitude!, nearest.lat, nearest.lng);

    final List<Bus> buses = <Bus>[];
    final Set<String> seen = <String>{};
    for (final RealStop stop in byDistance) {
      for (final String number in stop.buses) {
        if (seen.add(number)) buses.add(MockData.busByNumber(number));
      }
      if (buses.length >= 3) break;
    }
    if (buses.isEmpty || !mounted) return;

    setState(() {
      _nearbyBuses = buses.take(3).toList();
      _nearestStopLabel = distanceKm < 1
          ? 'Near ${nearest.name} · ${(distanceKm * 1000).round()} m away'
          : 'Near ${nearest.name} · ${distanceKm.toStringAsFixed(1)} km away';
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.pageBg,
      floatingActionButton: FloatingActionButton(
        heroTag: 'ai-assistant-fab',
        tooltip: s.t('ai_assistant'),
        backgroundColor: AppColors.brand,
        onPressed: () => pushPage(context, const AiAssistantScreen()),
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Builder(
              builder: (BuildContext ctx) => AppHeader(
                onMenu: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: <Widget>[
                  const GreetingBlock(),
                  const SizedBox(height: 16),
                  const SmartSearchBar(),
                  const SizedBox(height: 22),

                  // --- Quick Actions --------------------------------------
                  SectionHeader(
                    title: s.t('quick_actions'),
                    actionLabel: s.t('view_all'),
                    onAction: () => s.setTab(1),
                  ),
                  _QuickActionsGrid(),
                  const SizedBox(height: 22),

                  // --- Buses Near You -----------------------------------
                  SectionHeader(
                    title: s.t('buses_near_you'),
                    actionLabel: s.t('view_all'),
                    onAction: () => s.setTab(3),
                  ),
                  if (_nearestStopLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.my_location_rounded, size: 13, color: AppColors.brand),
                          const SizedBox(width: 4),
                          Text(_nearestStopLabel!,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.inkSoft,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ...List<Widget>.generate(_nearbyBuses.length, (int i) {
                    final Bus bus = _nearbyBuses[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: i == _nearbyBuses.length - 1 ? 0 : 10),
                      child: BusCard(bus: bus, showStatus: i == 0),
                    );
                  }),
                  const SizedBox(height: 22),

                  // --- Frequent Journeys -------------------------------
                  SectionHeader(
                    title: s.t('frequent_journeys'),
                    actionLabel: s.t('manage'),
                    onAction: () => pushPage(context, const FavouritesScreen()),
                  ),
                  _FrequentJourneys(),
                  const SizedBox(height: 22),

                  // --- Service Update ---------------------------------
                  ServiceUpdateBanner(
                    update: MockData.serviceUpdates.first,
                    onView: () => pushPage(context, const ServiceUpdatesScreen()),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    final List<Widget> cards = <Widget>[
      QuickAction(
        icon: Icons.directions_bus_rounded,
        label: s.t('track_bus'),
        description: s.t('track_bus_desc'),
        color: AppColors.brand,
        onTap: () => s.setTab(3),
      ),
      QuickAction(
        icon: Icons.alt_route_rounded,
        label: s.t('plan_journey'),
        description: s.t('plan_journey_desc'),
        color: AppColors.live,
        onTap: () => s.setTab(1),
      ),
      QuickAction(
        icon: Icons.confirmation_number_rounded,
        label: s.t('buy_ticket'),
        description: s.t('buy_ticket_desc'),
        color: AppColors.warn,
        onTap: () => pushPage(context, const BuyTicketScreen()),
      ),
      QuickAction(
        icon: Icons.credit_card_rounded,
        label: s.t('passes'),
        description: s.t('passes_desc'),
        color: AppColors.purple,
        onTap: () => s.openTickets(2),
      ),
    ];

    return Column(
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrequentJourneys extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final List<FrequentJourney> list = s.favourites;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: <Widget>[
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.star_border_rounded, color: AppColors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('No saved journeys yet. Add one for one-tap access.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
                  ),
                ],
              ),
            )
          else
            for (int i = 0; i < list.length && i < 3; i++) ...<Widget>[
              if (i != 0) const Divider(height: 1),
              JourneyCard(
                journey: list[i],
                onOpen: () => s.openPlanner(list[i].from, list[i].to),
              ),
            ],
          const Divider(height: 1),
          InkWell(
            onTap: () => pushPage(context, const FavouritesScreen()),
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add_rounded, size: 18, color: AppColors.brand),
                  SizedBox(width: 6),
                  Text('Add favourite journey',
                      style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.brand, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
