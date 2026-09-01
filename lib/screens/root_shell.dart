import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/bottom_navigation.dart';
import 'home_screen.dart';
import 'journey_planner_screen.dart';
import 'profile_screen.dart';
import 'tickets_screen.dart';
import 'track_bus_screen.dart';

/// Holds the five tab roots in an [IndexedStack] so each tab keeps its scroll
/// position and state. Detail screens are pushed on top with [Navigator], which
/// gives real Android back-button behaviour for free.
class RootShell extends StatelessWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    const List<Widget> tabs = <Widget>[
      HomeScreen(),
      JourneyPlannerScreen(embedded: true),
      TicketsScreen(embedded: true),
      TrackBusScreen(embedded: true),
      ProfileScreen(embedded: true),
    ];

    return Scaffold(
      body: IndexedStack(index: s.tabIndex, children: tabs),
      bottomNavigationBar: MbmtBottomNav(
        currentIndex: s.tabIndex,
        onTap: s.setTab,
      ),
    );
  }
}
