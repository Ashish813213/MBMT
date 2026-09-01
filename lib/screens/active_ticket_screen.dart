import 'package:flutter/material.dart';

import '../models/models.dart';
import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/qr_view.dart';
import 'tracking_screen.dart';

class ActiveTicketScreen extends StatelessWidget {
  const ActiveTicketScreen({super.key, required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: Text(s.t('my_ticket')),
        actions: <Widget>[
          IconButton(
            tooltip: s.t('share_ticket'),
            onPressed: () => showToast(context, 'Ticket link copied - ready to share',
                icon: Icons.ios_share_rounded),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: AppColors.live,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.live),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: const Row(
              children: <Widget>[
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Payment successful · Ticket active',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _TicketBody(ticket: ticket),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showToast(context, 'Ticket link copied - ready to share',
                      icon: Icons.ios_share_rounded),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: Text(s.t('share_ticket')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => pushPage(context, TrackingScreen(busNumber: ticket.route)),
                  icon: const Icon(Icons.near_me_rounded, size: 18),
                  label: Text(s.t('view_journey')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton.icon(
              onPressed: () {
                s.setTab(2);
                s.setTicketsSegment(0);
                Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
              },
              icon: const Icon(Icons.confirmation_number_outlined, size: 16),
              label: const Text('Go to my tickets'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({required this.ticket});
  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Column(
          children: <Widget>[
            // header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: <Color>[AppColors.live, AppColors.live700]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('MBMT',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                      ),
                      const Spacer(),
                      const Text('DIGITAL TICKET',
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(ticket.from,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ),
                      Flexible(
                        child: Text(ticket.to,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // body
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              foregroundDecoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: _kv('Route', 'Bus ${ticket.route}')),
                      Expanded(child: _kv('Ticket ID', ticket.id)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(child: _kv('Date', ticket.date)),
                      Expanded(child: _kv('Time', ticket.time)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(child: _kv('Bus No.', ticket.vehicleNo)),
                      Expanded(child: _kv('Passenger', ticket.passengers)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(child: _kv('Fare paid', '\u{20B9}${ticket.fare}')),
                      Expanded(
                        child: _kv('Status', 'Active', valueColor: AppColors.live),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: _DashedLine(),
                  ),
                  QrView(data: ticket.id, size: 168),
                  const SizedBox(height: 10),
                  Text('Show this QR to the conductor while travelling',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                ],
              ),
            ),
          ],
        );
  }

  Widget _kv(String k, String v, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(k, style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(v,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: valueColor ?? AppColors.ink)),
      ],
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        const double dash = 6;
        const double gap = 5;
        final int count = (c.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            count,
            (_) => Container(width: dash, height: 2, color: AppColors.line),
          ),
        );
      },
    );
  }
}
