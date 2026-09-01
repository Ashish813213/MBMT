import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// Small coloured status chip for a bus / trip.
///
/// Green = arriving / on time, Orange = delayed. (Red is reserved for
/// cancellations elsewhere in the app.)
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.dense = false});

  final BusStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icon;
    late final String text;

    switch (status) {
      case BusStatus.arriving:
        color = AppColors.live;
        icon = Icons.near_me_rounded;
        text = 'Arriving soon';
        break;
      case BusStatus.onTime:
        color = AppColors.live;
        icon = Icons.check_circle_rounded;
        text = 'On time';
        break;
      case BusStatus.delayed:
        color = AppColors.warn;
        icon = Icons.access_time_rounded;
        text = 'Delayed';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 7 : 9, vertical: dense ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: dense ? 12 : 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: dense ? 10.5 : 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// A tiny pulsing "live" dot.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.color = AppColors.live, this.size = 9, this.animate});

  final Color color;
  final double size;

  /// null -> follow MediaQuery.disableAnimations.
  final bool? animate;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool animate = widget.animate ?? !MediaQuery.of(context).disableAnimations;
    if (!animate) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }
    return SizedBox(
      width: widget.size * 2.4,
      height: widget.size * 2.4,
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, Widget? child) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Opacity(
                opacity: (1 - _c.value).clamp(0.0, 1.0) * 0.5,
                child: Container(
                  width: widget.size + widget.size * 1.6 * _c.value,
                  height: widget.size + widget.size * 1.6 * _c.value,
                  decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
              ),
            ],
          );
        },
      ),
    );
  }
}
