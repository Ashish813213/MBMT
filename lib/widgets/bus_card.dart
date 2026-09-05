import 'package:flutter/material.dart';

import '../models/models.dart';
import '../nav.dart';
import '../screens/tracking_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'crowd_indicator.dart';
import 'status_badge.dart';

/// A "Buses Near You" row. Whole card -> live tracking. The pin button is a
/// dedicated shortcut to the same tracking / map view.
class BusCard extends StatelessWidget {
  const BusCard({super.key, required this.bus, this.showStatus = false});

  final Bus bus;
  final bool showStatus;

  void _openTracking(BuildContext context) {
    pushPage(context, TrackingScreen(busNumber: bus.number));
  }

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final String lang = s.language;
    return Semantics(
      button: true,
      label:
          'Bus ${bus.number} to ${bus.destination} via ${bus.via}. Arrives in ${bus.etaMin} minutes. Fare ${bus.fare} rupees. ${bus.crowd.shortLabelOf(lang)}.',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _openTracking(context),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                _RouteChip(number: bus.number),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        bus.destination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Via ${bus.via}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          CrowdIndicator(bus.crowd, compact: true),
                          if (showStatus) StatusBadge(bus.status, dense: true),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${bus.etaMin} min',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.live,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${bus.fare}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    _PinButton(onTap: () => _openTracking(context)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteChip extends StatelessWidget {
  const _RouteChip({required this.number});
  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.brand, AppColors.brandDark],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        number,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }
}

class _PinButton extends StatelessWidget {
  const _PinButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open on map',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.location_on_rounded, size: 18, color: AppColors.brand),
        ),
      ),
    );
  }
}
