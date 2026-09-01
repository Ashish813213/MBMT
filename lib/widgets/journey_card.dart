import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// A row in "Your Frequent Journeys".
class JourneyCard extends StatelessWidget {
  const JourneyCard({
    super.key,
    required this.journey,
    required this.onOpen,
    this.onRemove,
  });

  final FrequentJourney journey;
  final VoidCallback onOpen;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        child: Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.brandSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.home_rounded, size: 18, color: AppColors.brand),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          journey.from,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.muted),
                      ),
                      Flexible(
                        child: Text(
                          journey.to,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        const TextSpan(
                          text: 'Next bus ',
                          style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                        ),
                        TextSpan(
                          text: 'in ${journey.nextBusMin} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.live,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: '  ·  Bus ${journey.busNumber}',
                          style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: 'Remove journey',
                visualDensity: VisualDensity.compact,
                color: AppColors.muted,
              )
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
