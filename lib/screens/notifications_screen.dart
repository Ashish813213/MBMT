import 'package:flutter/material.dart';

import '../models/models.dart';
import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'service_updates_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final List<AppNotification> items = s.notifications;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          if (s.unreadCount > 0)
            TextButton(
              onPressed: () {
                s.markAllNotificationsRead();
                showToast(context, 'All notifications marked as read');
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        separatorBuilder: (BuildContext _, int __) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int i) {
          final AppNotification n = items[i];
          return Container(
            decoration: BoxDecoration(
              color: n.read ? AppColors.surface : AppColors.brandSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: n.read ? Theme.of(context).colorScheme.outline : AppColors.brand.withOpacity(0.35),
              ),
            ),
            child: InkWell(
              onTap: () => pushPage(context, const ServiceUpdatesScreen()),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: n.tint.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(n.icon, color: n.tint, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(n.title,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                              ),
                              if (!n.read)
                                Container(
                                  margin: const EdgeInsets.only(left: 8, top: 4),
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                      color: AppColors.brand, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(n.body,
                              style: const TextStyle(fontSize: 12.5, height: 1.35, color: AppColors.inkSoft)),
                          const SizedBox(height: 4),
                          Text(n.ago,
                              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
