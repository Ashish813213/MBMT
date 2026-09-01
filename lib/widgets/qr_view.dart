import 'package:flutter/material.dart';

/// A QR-*style* code rendered with a [CustomPainter].
///
/// NOTE: this is a deterministic visual stand-in for a real QR symbol - it is
/// generated from [data] so it looks stable and "real" for a presentation, but
/// it is not a scannable QR payload. Swapping in the `qr_flutter` package later
/// is a one-line change in [ActiveTicketScreen]. Kept dependency-free so the
/// project builds offline with only the Flutter SDK.
class QrView extends StatelessWidget {
  const QrView({
    super.key,
    required this.data,
    this.size = 150,
    this.moduleCount = 25,
    this.foreground = const Color(0xFF0F172A),
    this.background = Colors.white,
  });

  final String data;
  final double size;
  final int moduleCount;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'QR code for ticket $data',
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: CustomPaint(
          painter: _QrPainter(
            data: data,
            moduleCount: moduleCount,
            foreground: foreground,
            background: background,
          ),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter({
    required this.data,
    required this.moduleCount,
    required this.foreground,
    required this.background,
  });

  final String data;
  final int moduleCount;
  final Color foreground;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final int n = moduleCount;
    final double m = size.width / n;
    final Paint fg = Paint()..color = foreground;
    final Paint bg = Paint()..color = background;

    canvas.drawRect(Offset.zero & size, bg);

    final List<List<bool>> grid =
        List<List<bool>>.generate(n, (_) => List<bool>.filled(n, false));
    final List<List<bool>> reserved =
        List<List<bool>>.generate(n, (_) => List<bool>.filled(n, false));

    void finder(int ox, int oy) {
      for (int y = 0; y < 7; y++) {
        for (int x = 0; x < 7; x++) {
          final bool edge = x == 0 || x == 6 || y == 0 || y == 6;
          final bool core = x >= 2 && x <= 4 && y >= 2 && y <= 4;
          grid[oy + y][ox + x] = edge || core;
          reserved[oy + y][ox + x] = true;
        }
      }
      // separator ring
      for (int i = -1; i <= 7; i++) {
        for (final List<int> p in <List<int>>[
          <int>[ox + i, oy - 1],
          <int>[ox + i, oy + 7],
          <int>[ox - 1, oy + i],
          <int>[ox + 7, oy + i],
        ]) {
          if (p[0] >= 0 && p[0] < n && p[1] >= 0 && p[1] < n) {
            reserved[p[1]][p[0]] = true;
          }
        }
      }
    }

    finder(0, 0);
    finder(n - 7, 0);
    finder(0, n - 7);

    // timing patterns
    for (int i = 8; i < n - 8; i++) {
      grid[6][i] = i.isEven;
      grid[i][6] = i.isEven;
      reserved[6][i] = true;
      reserved[i][6] = true;
    }

    // alignment pattern (bottom-right-ish)
    final int ax = n - 9;
    final int ay = n - 9;
    for (int y = 0; y < 5; y++) {
      for (int x = 0; x < 5; x++) {
        final bool edge = x == 0 || x == 4 || y == 0 || y == 4;
        final bool center = x == 2 && y == 2;
        grid[ay + y][ax + x] = edge || center;
        reserved[ay + y][ax + x] = true;
      }
    }

    // deterministic data fill
    int seed = 0x811C9DC5;
    for (final int code in data.codeUnits) {
      seed = (seed ^ code) & 0xFFFFFFFF;
      seed = (seed * 0x01000193) & 0xFFFFFFFF;
    }
    int rnd() {
      seed ^= (seed << 13) & 0xFFFFFFFF;
      seed ^= seed >> 17;
      seed ^= (seed << 5) & 0xFFFFFFFF;
      return seed & 0xFFFFFFFF;
    }

    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if (reserved[y][x]) continue;
        grid[y][x] = rnd() % 100 < 47;
      }
    }

    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if (grid[y][x]) {
          canvas.drawRect(
            Rect.fromLTWH(x * m, y * m, m + 0.5, m + 0.5),
            fg,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) =>
      old.data != data ||
      old.moduleCount != moduleCount ||
      old.foreground != foreground;
}
