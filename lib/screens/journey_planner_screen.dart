import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/crowd_indicator.dart';
import '../widgets/pickers.dart';
import '../widgets/route_card.dart';
import 'tracking_screen.dart';

class JourneyPlannerScreen extends StatelessWidget {
  const JourneyPlannerScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final RouteOption? selected = s.selectedRoute;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Plan Your Journey'),
      ),
      bottomNavigationBar: (s.plannerShowResults && selected != null)
          ? _TrackCta(route: selected)
          : null,
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          _TripCard(),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => s.setPlanner(showResults: true),
            icon: const Icon(Icons.search_rounded),
            label: Text(s.t('find_best_routes')),
          ),
          if (s.plannerShowResults) ...<Widget>[
            const SizedBox(height: 22),
            Row(
              children: <Widget>[
                const Text('Best options',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text('${MockData.routeOptions.length} routes',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 6),
            const Align(alignment: Alignment.centerLeft, child: CrowdLegend()),
            const SizedBox(height: 12),
            ...MockData.routeOptions.map(
              (RouteOption r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RouteCard(
                  route: r,
                  selected: selected?.id == r.id,
                  onSelect: () => s.selectRoute(r),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                selected == null
                    ? 'Tap a route to select it'
                    : 'Selected: ${selected.tagLabel} · Bus ${selected.busNumber}',
                style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    Widget endpoint({
      required IconData icon,
      required Color color,
      required String label,
      required String value,
      required VoidCallback onTap,
      Widget? trailing,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: <Widget>[
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label,
                        style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 1),
                    Text(value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ?? const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.muted),
            ],
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    endpoint(
                      icon: Icons.trip_origin_rounded,
                      color: AppColors.brand,
                      label: s.t('from').toUpperCase(),
                      value: s.plannerFrom,
                      trailing: const SizedBox(width: 18),
                      onTap: () async {
                        final String? v = await pickStop(context,
                            title: 'Choose starting point', current: s.plannerFrom);
                        if (v != null) s.setPlanner(from: v, showResults: false);
                      },
                    ),
                    const Divider(height: 1),
                    endpoint(
                      icon: Icons.place_rounded,
                      color: AppColors.danger,
                      label: s.t('to').toUpperCase(),
                      value: s.plannerTo,
                      trailing: const SizedBox(width: 18),
                      onTap: () async {
                        final String? v = await pickStop(context,
                            title: 'Choose destination', current: s.plannerTo);
                        if (v != null) s.setPlanner(to: v, showResults: false);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Material(
                color: AppColors.surface,
                shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
                child: IconButton(
                  tooltip: 'Swap from and to',
                  icon: const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.brand),
                  onPressed: s.swapPlannerEnds,
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          endpoint(
            icon: Icons.schedule_rounded,
            color: AppColors.inkSoft,
            label: s.t('departure').toUpperCase(),
            value: s.plannerWhen,
            onTap: () async {
              final String? v = await pickOption(
                context,
                title: 'Departure time',
                current: s.plannerWhen,
                options: const <String>['Now', 'In 15 min', 'In 30 min', 'In 1 hour'],
              );
              if (v != null) s.setPlanner(when: v);
            },
          ),
        ],
      ),
    );
  }
}

class _TrackCta extends StatelessWidget {
  const _TrackCta({required this.route});
  final RouteOption route;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SafeArea(
        top: false,
        child: FilledButton.icon(
          onPressed: () => pushPage(context, TrackingScreen(busNumber: route.busNumber)),
          icon: const Icon(Icons.near_me_rounded),
          label: Text('Start live tracking · Bus ${route.busNumber}'),
        ),
      ),
    );
  }
}
