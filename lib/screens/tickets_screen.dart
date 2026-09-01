import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/ticket_card.dart';
import 'active_ticket_screen.dart';
import 'buy_ticket_screen.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final int seg = s.ticketsSegment;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Tickets & Passes'),
      ),
      floatingActionButton: seg == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => pushPage(context, const BuyTicketScreen()),
              backgroundColor: AppColors.brand,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buy ticket'),
            ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: _Segmented(
              value: seg,
              labels: <String>[s.t('active'), s.t('history'), s.t('my_passes')],
              onChanged: s.setTicketsSegment,
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: seg,
              children: <Widget>[
                _ActiveTab(),
                _HistoryTab(),
                _PassesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.value, required this.labels, required this.onChanged});
  final int value;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: List<Widget>.generate(labels.length, (int i) {
          final bool active = i == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? AppColors.brand : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : AppColors.inkSoft,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ActiveTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final List<Ticket> active = s.activeTickets;

    if (active.isEmpty) {
      return _Empty(
        icon: Icons.confirmation_number_outlined,
        title: 'No active tickets',
        message: 'Buy a digital ticket and it will appear here with a QR code for the conductor.',
        actionLabel: 'Buy a ticket',
        onAction: () => pushPage(context, const BuyTicketScreen()),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: active.length,
      separatorBuilder: (BuildContext _, int __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int i) {
        final Ticket t = active[i];
        return TicketCard(
          ticket: t,
          onTap: () => pushPage(context, ActiveTicketScreen(ticket: t)),
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final List<Ticket> past = s.pastTickets;

    if (past.isEmpty) {
      return const _Empty(
        icon: Icons.history_rounded,
        title: 'No past tickets',
        message: 'Your completed journeys will show up here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: past.length,
      separatorBuilder: (BuildContext _, int __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int i) => TicketCard(
        ticket: past[i],
        onTap: () => showToast(context, 'Ticket ${past[i].id}',
            icon: Icons.confirmation_number_rounded),
      ),
    );
  }
}

class _PassesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<TransitPass> active =
        MockData.passes.where((TransitPass p) => p.status == 'active').toList();
    final List<TransitPass> available =
        MockData.passes.where((TransitPass p) => p.status != 'active').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      children: <Widget>[
        const SectionHeader(title: 'Your active passes'),
        ...active.map((TransitPass p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PassCard(pass: p),
            )),
        const SizedBox(height: 10),
        const SectionHeader(title: 'Buy a pass'),
        ...available.map((TransitPass p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PassCard(pass: p),
            )),
      ],
    );
  }
}

class _PassCard extends StatelessWidget {
  const _PassCard({required this.pass});
  final TransitPass pass;

  @override
  Widget build(BuildContext context) {
    final bool active = pass.status == 'active';
    return Container(
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.brand, AppColors.brandDark],
              )
            : null,
        color: active ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: active ? null : Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.badge_rounded,
                  color: active ? Colors.white : AppColors.brand, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(pass.type,
                    style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: active ? Colors.white : AppColors.ink)),
              ),
              Text('\u{20B9}${pass.price}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: active ? Colors.white : AppColors.brand)),
            ],
          ),
          const SizedBox(height: 8),
          Text(pass.validity,
              style: TextStyle(
                  fontSize: 12.5,
                  color: active ? Colors.white70 : AppColors.inkSoft)),
          Text(pass.zone,
              style: TextStyle(
                  fontSize: 11.5,
                  color: active ? Colors.white60 : AppColors.muted)),
          const SizedBox(height: 12),
          if (active)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.check_circle_rounded, size: 13, color: Colors.white),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text('Active · bought ${pass.purchased ?? ''}'.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => showToast(context, '${pass.type} added — prototype only',
                    icon: Icons.badge_rounded),
                child: Text('Buy ${pass.type}'),
              ),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, size: 30, color: AppColors.brand),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4)),
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
