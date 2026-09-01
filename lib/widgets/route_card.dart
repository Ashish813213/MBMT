import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'crowd_indicator.dart';

/// A single recommended route in the Journey Planner. Clearly labelled
/// Fastest / Cheapest / Less Crowded.
class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.route,
    required this.selected,
    required this.onSelect,
  });

  final RouteOption route;
  final bool selected;
  final VoidCallback onSelect;

  Color get _tagColor {
    switch (route.tag) {
      case 'fastest':
        return AppColors.brand;
      case 'cheapest':
        return AppColors.live;
      case 'less-crowded':
        return AppColors.purple;
      default:
        return AppColors.inkSoft;
    }
  }

  IconData get _tagIcon {
    switch (route.tag) {
      case 'fastest':
        return Icons.bolt_rounded;
      case 'cheapest':
        return Icons.savings_rounded;
      case 'less-crowded':
        return Icons.airline_seat_recline_normal_rounded;
      default:
        return Icons.directions_bus_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.brand : Theme.of(context).colorScheme.outline,
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _tagColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(_tagIcon, size: 13, color: _tagColor),
                        const SizedBox(width: 4),
                        Text(route.tagLabel,
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _tagColor)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.brand, size: 20)
                  else
                    Text('Tap to select',
                        style: TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: <Color>[AppColors.brand, AppColors.brandDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(route.busNumber,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('${route.durationMin} min',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            const SizedBox(width: 10),
                            Text('₹${route.fare}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text('Via ${route.via}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                        const SizedBox(height: 2),
                        Text('Every ${route.headwayMin} min · ${route.firstBus}-${route.lastBus}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  const Icon(Icons.directions_bus_filled_rounded, size: 15, color: AppColors.live),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text('Bus arriving in ${route.arrivingInMin} min',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.live)),
                  ),
                  const SizedBox(width: 8),
                  CrowdIndicator(route.crowd, compact: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
