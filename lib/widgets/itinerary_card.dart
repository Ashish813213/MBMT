import 'package:flutter/material.dart';

import '../models/trip_models.dart';
import '../theme/app_theme.dart';

/// Renders a computed [TripItinerary] as a step-by-step timeline - which bus
/// to board, where to change, and where to walk - mirroring the visual
/// language of the live-tracking stops list elsewhere in the app.
class ItineraryCard extends StatelessWidget {
  const ItineraryCard({super.key, required this.itinerary});

  final TripItinerary itinerary;

  @override
  Widget build(BuildContext context) {
    if (itinerary.isSamePlace) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: const Text(
          'You are already there.',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 240),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: itinerary.isEstimate ? AppColors.warn.withOpacity(0.4) : AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${itinerary.originResolved} → ${itinerary.destinationResolved}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                ),
                if (itinerary.isEstimate) ...<Widget>[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warnSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Estimate',
                        style: TextStyle(
                            fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.warn)),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Wrap(
              spacing: 14,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                _Stat(icon: Icons.schedule_rounded, label: '${itinerary.totalDurationMin} min'),
                _Stat(icon: Icons.payments_rounded, label: '₹${itinerary.totalFare}'),
                if (itinerary.changeCount > 0)
                  _Stat(
                    icon: Icons.swap_horiz_rounded,
                    label:
                        '${itinerary.changeCount} change${itinerary.changeCount > 1 ? 's' : ''}',
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Divider(height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 14, 10),
            child: Column(
              children: List<Widget>.generate(itinerary.legs.length, (int i) {
                return _LegRow(
                  leg: itinerary.legs[i],
                  isLast: i == itinerary.legs.length - 1,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: AppColors.inkSoft),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
      ],
    );
  }
}

class _LegRow extends StatelessWidget {
  const _LegRow({required this.leg, required this.isLast});
  final TripLeg leg;
  final bool isLast;

  Color get _color {
    switch (leg.mode) {
      case TravelMode.bus:
        return AppColors.brand;
      case TravelMode.walk:
        return AppColors.inkSoft;
      case TravelMode.rickshaw:
        return AppColors.warn;
    }
  }

  IconData get _icon {
    switch (leg.mode) {
      case TravelMode.bus:
        return Icons.directions_bus_rounded;
      case TravelMode.walk:
        return Icons.directions_walk_rounded;
      case TravelMode.rickshaw:
        return Icons.local_taxi_rounded;
    }
  }

  String get _title {
    switch (leg.mode) {
      case TravelMode.bus:
        return 'Bus ${leg.busNumber}';
      case TravelMode.walk:
        return 'Walk';
      case TravelMode.rickshaw:
        return 'Auto-rickshaw';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: _color.withOpacity(0.14), shape: BoxShape.circle),
                child: Icon(_icon, size: 14, color: _color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 16, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(_title,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _color)),
                      if (leg.durationMin > 0)
                        Text('${leg.durationMin} min',
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                      if (leg.fare > 0)
                        Text('· ₹${leg.fare}',
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(leg.instruction,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.35)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
