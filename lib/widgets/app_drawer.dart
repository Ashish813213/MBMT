import 'package:flutter/material.dart';

import '../nav.dart';
import '../screens/accessibility_screen.dart';
import '../screens/service_updates_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Side menu opened from the home header hamburger.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    Widget tile(IconData icon, String label, VoidCallback onTap, {Color? color}) {
      return ListTile(
        leading: Icon(icon, color: color ?? AppColors.brand),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      );
    }

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: <Color>[AppColors.brand, AppColors.brandDark]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_bus_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('MBMT Smart Bus',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        Text('Mira-Bhayandar Municipal Transport',
                            style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: <Widget>[
                  tile(Icons.home_rounded, 'Home', () => s.setTab(0)),
                  tile(Icons.alt_route_rounded, 'Plan a journey', () => s.setTab(1)),
                  tile(Icons.near_me_rounded, 'Track a bus', () => s.setTab(3)),
                  tile(Icons.confirmation_number_rounded, 'Tickets & passes', () => s.openTickets(0)),
                  tile(Icons.campaign_rounded, 'Service updates',
                      () => pushPage(context, const ServiceUpdatesScreen()),
                      color: AppColors.warn),
                  tile(Icons.person_rounded, 'Profile', () => s.setTab(4)),
                  tile(Icons.accessibility_new_rounded, 'Accessibility',
                      () => pushPage(context, const AccessibilityScreen())),
                  const Divider(height: 1),
                  tile(Icons.info_outline_rounded, 'About MBMT', () => _about(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Proposed redesign concept · v1.0\nNot an official release',
                style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _about(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MBMT Smart Bus',
      applicationVersion: 'v1.0 · Proposed redesign concept',
      applicationIcon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: <Color>[AppColors.brand, AppColors.brandDark]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.directions_bus_rounded, color: Colors.white),
      ),
      children: const <Widget>[
        SizedBox(height: 8),
        Text(
          'A student concept for a modern, accessible public-transport app for '
          'Mira-Bhayandar Municipal Transport. All data shown is sample data for '
          'demonstration only. This is not an official MBMT product and does not '
          'reflect features of any live MBMT app.',
          style: TextStyle(height: 1.4),
        ),
      ],
    );
  }
}
