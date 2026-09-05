import 'dart:math' as math;
import 'dart:ui' show PathMetric, Tangent;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A stylised, self-contained "map" for the live tracking screen.
///
/// No tiles, no network, no packages - just a [CustomPainter] drawing a street
/// texture, the route polyline, stop dots, the user's stop and an animated bus
/// marker at [progress] (0..1 along the route).
class MiniMap extends StatelessWidget {
  const MiniMap({
    super.key,
    required this.stopCount,
    required this.progress,
    required this.userIndex,
    this.height = 230,
    this.animate = true,
  });

  final int stopCount;
  final double progress;
  final int userIndex;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final Widget map = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: progress, end: progress),
          duration: animate ? const Duration(milliseconds: 900) : Duration.zero,
          curve: Curves.easeInOut,
          builder: (BuildContext context, double p, _) {
            return CustomPaint(
              size: Size(c.maxWidth, height),
              painter: _MapPainter(
                stopCount: stopCount,
                progress: p,
                userIndex: userIndex,
              ),
            );
          },
        );
      },
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: height,
        width: double.infinity,
        color: const Color(0xFFEAF0F4),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: map),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.trip_origin_rounded, size: 11, color: AppColors.live),
                    SizedBox(width: 4),
                    Text('Live', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.stopCount,
    required this.progress,
    required this.userIndex,
  });

  final int stopCount;
  final double progress;
  final int userIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = const Color(0xFFE9EEF2));

    // --- soft "city blocks" texture ---------------------------------------
    final Paint block = Paint()..color = const Color(0xFFDDE5EA);
    final math.Random r = math.Random(7);
    for (int i = 0; i < 10; i++) {
      final double bx = r.nextDouble() * size.width;
      final double by = r.nextDouble() * size.height;
      final double bw = 26 + r.nextDouble() * 46;
      final double bh = 22 + r.nextDouble() * 40;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(bx, by, bw, bh), const Radius.circular(6)),
        block,
      );
    }

    // faint grid streets
    final Paint street = Paint()
      ..color = const Color(0xFFF3F6F8)
      ..strokeWidth = 6;
    for (double x = 24; x < size.width; x += 58) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), street);
    }
    for (double y = 20; y < size.height; y += 52) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), street);
    }

    // --- route polyline --------------------------------------------------
    final Path route = Path();
    final double w = size.width;
    final double h = size.height;
    route.moveTo(w * 0.10, h * 0.84);
    route.cubicTo(w * 0.28, h * 0.86, w * 0.30, h * 0.55, w * 0.46, h * 0.55);
    route.cubicTo(w * 0.63, h * 0.55, w * 0.58, h * 0.22, w * 0.90, h * 0.16);

    canvas.drawPath(
      route,
      Paint()
        ..color = AppColors.brand.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      route,
      Paint()
        ..color = AppColors.brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    final PathMetric metric = route.computeMetrics().first;
    final double total = metric.length;

    Offset at(double t) {
      final Tangent? tan = metric.getTangentForOffset((total * t).clamp(0.0, total));
      return tan?.position ?? Offset.zero;
    }

    // --- stop dots -----------------------------------------------------
    final int count = math.max(stopCount, 2);
    for (int i = 0; i < count; i++) {
      final double t = i / (count - 1);
      final Offset pos = at(t);
      final bool isEnd = i == count - 1;
      final bool isUser = i == userIndex;
      canvas.drawCircle(pos, isEnd ? 7 : 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        pos,
        isEnd ? 7 : 5,
        Paint()
          ..color = isEnd ? AppColors.danger : AppColors.brand
          ..style = PaintingStyle.stroke
          ..strokeWidth = isEnd ? 3 : 2.4,
      );
      if (isUser && !isEnd) {
        canvas.drawCircle(pos, 12, Paint()..color = AppColors.brand.withOpacity(0.16));
      }
    }

    // --- bus marker --------------------------------------------------
    final Offset busPos = at(progress.clamp(0.0, 1.0));
    canvas.drawCircle(busPos, 17, Paint()..color = AppColors.live.withOpacity(0.18));
    canvas.drawCircle(busPos, 12, Paint()..color = Colors.white);
    canvas.drawCircle(busPos, 12, Paint()..color = AppColors.live..style = PaintingStyle.stroke..strokeWidth = 3);
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.directions_bus_rounded.codePoint),
        style: const TextStyle(
          fontSize: 13,
          fontFamily: 'MaterialIcons',
          color: AppColors.live,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, busPos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) =>
      old.progress != progress ||
      old.stopCount != stopCount ||
      old.userIndex != userIndex;
}
