import 'package:flutter/material.dart';

import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'accessibility_screen.dart';
import 'favourites_screen.dart';
import 'language_screen.dart';
import 'profile_subscreens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    final String langLabel = switch (s.language) {
      'hi' => 'हिन्दी',
      'mr' => 'मराठी',
      _ => 'English',
    };

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: <Widget>[
          // --- user header -------------------------------------------------
          AppCard(
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.brandSoft,
                  child: const Text('A',
                      style: TextStyle(
                          color: AppColors.brandDark, fontWeight: FontWeight.w900, fontSize: 22)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Ashish',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('+91 98XXX XXX21',
                          style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.liveSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('MBMT member',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.live700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _Group(children: <Widget>[
            NavRow(
              icon: Icons.confirmation_number_rounded,
              title: 'My Tickets',
              subtitle: '${s.tickets.length} tickets',
              onTap: () => s.openTickets(0),
            ),
            const Divider(height: 1),
            NavRow(
              icon: Icons.badge_rounded,
              iconColor: AppColors.purple,
              title: 'My Passes',
              subtitle: 'Daily · Weekly · Monthly',
              onTap: () => s.openTickets(2),
            ),
            const Divider(height: 1),
            NavRow(
              icon: Icons.star_rounded,
              iconColor: AppColors.warn,
              title: 'Favourite Journeys',
              subtitle: '${s.favourites.length} saved',
              onTap: () => pushPage(context, const FavouritesScreen()),
            ),
            const Divider(height: 1),
            NavRow(
              icon: Icons.credit_card_rounded,
              title: 'Payment Methods',
              onTap: () => pushPage(context, const PaymentMethodsScreen()),
            ),
          ]),
          const SizedBox(height: 14),

          _Group(children: <Widget>[
            NavRow(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              onTap: () => pushPage(context, const NotificationPrefsScreen()),
            ),
            const Divider(height: 1),
            NavRow(
              icon: Icons.translate_rounded,
              title: 'Language',
              subtitle: langLabel,
              onTap: () => pushPage(context, const LanguageScreen()),
            ),
            const Divider(height: 1),
            NavRow(
              icon: Icons.accessibility_new_rounded,
              title: 'Accessibility',
              subtitle: 'Large text, high contrast, more',
              onTap: () => pushPage(context, const AccessibilityScreen()),
            ),
          ]),
          const SizedBox(height: 14),

          _Group(children: <Widget>[
            NavRow(
              icon: Icons.help_rounded,
              title: 'Help & Support',
              onTap: () => pushPage(context, const HelpScreen()),
            ),
            const Divider(height: 1),
            NavRow(
              icon: Icons.rate_review_rounded,
              title: 'Feedback',
              onTap: () => pushPage(context, const FeedbackScreen()),
            ),
            const Divider(height: 1),
            NavRow(
              icon: Icons.info_rounded,
              title: 'About MBMT',
              onTap: () => pushPage(context, const AboutScreen()),
            ),
          ]),
          const SizedBox(height: 18),

          Center(
            child: Text('Proposed redesign concept · not an official release',
                style: TextStyle(fontSize: 11, color: AppColors.muted)),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Column(children: children),
    );
  }
}
