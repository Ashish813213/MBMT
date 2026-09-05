import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../nav.dart';
import '../screens/notifications_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Home dashboard header: menu, current location, notifications + badge, avatar.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.onMenu});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu',
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _pickLocation(context, s),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.location_on_rounded, size: 18, color: AppColors.brand),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        s.location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.inkSoft),
                  ],
                ),
              ),
            ),
          ),
          _NotificationButton(count: s.unreadCount),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () => s.setTab(4),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.brandSoft,
              child: Text(
                'A',
                style: TextStyle(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _pickLocation(BuildContext context, AppState s) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text('Set your location',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              for (final String loc in MockData.locations)
                ListTile(
                  leading: Icon(
                    loc == s.location ? Icons.radio_button_checked_rounded : Icons.location_on_outlined,
                    color: loc == s.location ? AppColors.brand : AppColors.muted,
                  ),
                  title: Text(loc, style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    s.location = loc;
                    Navigator.pop(ctx);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        IconButton(
          onPressed: () => pushPage(context, const NotificationsScreen()),
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
          visualDensity: VisualDensity.compact,
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A shared, styled "greeting" block for the top of the home screen.
class GreetingBlock extends StatelessWidget {
  const GreetingBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final int hour = DateTime.now().hour;
    final String key = hour < 12
        ? 'greeting_morning'
        : hour < 17
            ? 'greeting_afternoon'
            : 'greeting_evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                s.t(key),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
            ),
const SizedBox(width: 6),
              const Icon(Icons.waving_hand_rounded, size: 22),
             ],
        ),
        const SizedBox(height: 2),
        Text(
          s.t('plan_subtitle'),
          style: const TextStyle(fontSize: 13.5, color: AppColors.inkSoft),
        ),
      ],
    );
  }
}
