import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class UpdateStyle {
  final Color color;
  final IconData icon;
  const UpdateStyle(this.color, this.icon);
}

UpdateStyle styleFor(UpdateType type) {
  switch (type) {
    case UpdateType.diversion:
      return const UpdateStyle(AppColors.warn, Icons.alt_route_rounded);
    case UpdateType.delay:
      return const UpdateStyle(AppColors.warn, Icons.schedule_rounded);
    case UpdateType.cancellation:
      return const UpdateStyle(AppColors.danger, Icons.cancel_rounded);
    case UpdateType.information:
      return const UpdateStyle(AppColors.brand, Icons.info_rounded);
  }
}

/// Compact announcement card shown on the home dashboard.
class ServiceUpdateBanner extends StatelessWidget {
  const ServiceUpdateBanner({super.key, required this.update, required this.onView});

  final ServiceUpdate update;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final UpdateStyle st = styleFor(update.type);
    return Container(
      decoration: BoxDecoration(
        color: st.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: st.color.withOpacity(0.28)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: st.color, borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Service Update',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  update.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text('Updated ${update.ago}',
                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: onView,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('View\nDetails', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

/// Full card used on the Service Updates page.
class ServiceUpdateCard extends StatelessWidget {
  const ServiceUpdateCard({super.key, required this.update});

  final ServiceUpdate update;

  @override
  Widget build(BuildContext context) {
    final UpdateStyle st = styleFor(update.type);
    final AppState s = AppScope.of(context);
    final String lang = s.language;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: st.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(st.icon, size: 13, color: st.color),
                    const SizedBox(width: 4),
Text(
                       update.type.labelOf(lang),
                       style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: st.color),
                     ),
                  ],
                ),
              ),
              const Spacer(),
              const SizedBox(width: 8),
              Flexible(
                child: Text(update.ago,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(update.route,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(update.body,
              style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4)),
        ],
      ),
    );
  }
}
