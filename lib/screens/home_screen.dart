import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
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
import 'buy_ticket_screen.dart';
import 'favourites_screen.dart';
import 'service_updates_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.pageBg,
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                  ...List<Widget>.generate(3, (int i) {
                    final Bus bus = MockData.nearbyBuses[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: i == 2 ? 0 : 10),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
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
