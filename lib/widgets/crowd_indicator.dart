import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

Color crowdColor(Crowd c) {
  switch (c) {
    case Crowd.low:
      return AppColors.live;
    case Crowd.medium:
      return AppColors.warn;
    case Crowd.high:
      return AppColors.danger;
  }
}

/// Three-person glyph tinted by crowd level, with a text label.
/// Green = Low, Yellow/Orange = Medium, Red = High.
class CrowdIndicator extends StatelessWidget {
  const CrowdIndicator(this.crowd, {super.key, this.compact = false});

  final Crowd crowd;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color c = crowdColor(crowd);
    final int filled = crowd == Crowd.low
        ? 1
        : crowd == Crowd.medium
            ? 2
            : 3;

    return Semantics(
      label: 'Crowd level: ${crowd.label}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(3, (int i) {
              return Padding(
                padding: const EdgeInsets.only(right: 1.5),
                child: Icon(
                  Icons.person,
                  size: 14,
                  color: i < filled ? c : c.withOpacity(0.22),
                ),
              );
            }),
          ),
          const SizedBox(width: 6),
          Text(
            compact ? crowd.shortLabel : crowd.label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c),
          ),
        ],
      ),
    );
  }
}

/// Legend used on the Journey Planner / help surfaces.
class CrowdLegend extends StatelessWidget {
  const CrowdLegend({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item(Crowd c) => Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: crowdColor(c), shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(c.shortLabel, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
          ],
        );

    return Row(
      children: <Widget>[
        item(Crowd.low),
        const SizedBox(width: 14),
        item(Crowd.medium),
        const SizedBox(width: 14),
        item(Crowd.high),
      ],
    );
  }
}
