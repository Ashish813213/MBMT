import 'package:flutter/material.dart';

import '../models/models.dart';
import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/pickers.dart';
import '../data/mock_data.dart';
import 'payment_screen.dart';

class BuyTicketScreen extends StatelessWidget {
  const BuyTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final TicketDraft d = s.ticketDraft;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Buy Ticket')),
      bottomNavigationBar: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SafeArea(
          top: false,
          child: FilledButton(
            onPressed: () => pushPage(context, const PaymentScreen()),
            child: Text('${s.t('proceed_to_pay')}  ·  \u{20B9}${d.total}'),
          ),
        ),
      ),
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Column(
              children: <Widget>[
                _Field(
                  icon: Icons.trip_origin_rounded,
                  color: AppColors.brand,
                  label: 'FROM',
                  value: d.from,
                  onTap: () async {
                    final String? v = await pickStop(context, title: 'From', current: d.from);
                    if (v != null) s.setTicketDraft(d.copyWith(from: v));
                  },
                ),
                const Divider(height: 1),
                _Field(
                  icon: Icons.place_rounded,
                  color: AppColors.danger,
                  label: 'TO',
                  value: d.to,
                  onTap: () async {
                    final String? v = await pickStop(context, title: 'To', current: d.to);
                    if (v != null) s.setTicketDraft(d.copyWith(to: v));
                  },
                ),
                const Divider(height: 1),
                  _Field(
                   icon: Icons.event_rounded,
                   color: AppColors.inkSoft,
                   label: 'JOURNEY DATE',
                   value: d.date,
                   onTap: () async {
                     final String? v = await pickOption(
                       context,
                       title: 'Journey date',
                       current: d.date,
                       options: const <String>['Today', 'Tomorrow'],
                     );
                     if (v != null) {
                       final int fare = MockData.fareForRoute(d.route);
                       s.setTicketDraft(d.copyWith(date: v, fare: fare));
                     }
                   },
                 ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          AppCard(
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Number of tickets',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Adult · Route fare applies',
                          style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                    ],
                  ),
                ),
                _Stepper(
                  value: d.count,
                  onChanged: (int v) => s.setTicketDraft(d.copyWith(count: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          SectionHeader(title: 'Fare summary'),
          AppCard(
            child: Column(
              children: <Widget>[
                InfoRow('Route', 'Bus ${d.route} · via route stops'),
                const Divider(height: 16),
                InfoRow('Adult ticket  ×${d.count}', '\u{20B9}${d.fare * d.count}'),
                const Divider(height: 16),
                InfoRow('Total', '\u{20B9}${d.total}', bold: true, valueColor: AppColors.brand),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(Icons.verified_user_rounded, size: 15, color: AppColors.live),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Digital ticket valid for today\'s travel on the selected route.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 1),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget b(IconData icon, VoidCallback? onTap) => Material(
          color: onTap == null ? AppColors.surfaceAlt : AppColors.brandSoft,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(icon, size: 18, color: onTap == null ? AppColors.muted : AppColors.brand),
            ),
          ),
        );

    return Row(
      children: <Widget>[
        b(Icons.remove_rounded, value > 1 ? () => onChanged(value - 1) : null),
        SizedBox(
          width: 40,
          child: Text('$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ),
        b(Icons.add_rounded, value < 6 ? () => onChanged(value + 1) : null),
      ],
    );
  }
}
