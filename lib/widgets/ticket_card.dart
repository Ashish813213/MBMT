import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

class TicketStatusStyle {
  final Color color;
  final String label;
  const TicketStatusStyle(this.color, this.label);
}

TicketStatusStyle ticketStatusStyle(String status) {
  switch (status) {
    case 'active':
      return const TicketStatusStyle(AppColors.live, 'Active');
    case 'completed':
      return const TicketStatusStyle(AppColors.brand, 'Completed');
    case 'expired':
      return const TicketStatusStyle(AppColors.muted, 'Expired');
    default:
      return TicketStatusStyle(AppColors.inkSoft, status);
  }
}

/// Compact ticket row used in the Tickets history / active list.
class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket, this.onTap});

  final Ticket ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TicketStatusStyle st = ticketStatusStyle(ticket.status);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.brandSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Route ${ticket.route}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.brandDark)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: st.color.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(st.label,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: st.color)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(ticket.from,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.muted),
                  ),
                  Flexible(
                    child: Text(ticket.to,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  const Icon(Icons.event_rounded, size: 13, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('${ticket.date} · ${ticket.time}',
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                  const Spacer(),
                  Text('₹${ticket.fare}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
