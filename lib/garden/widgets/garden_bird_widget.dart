import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Minimal bird silhouettes: a small flock every ~12s, smooth horizontal pass.
class BirdsWidget extends StatefulWidget {
  const BirdsWidget({super.key});

  @override
  State<BirdsWidget> createState() => _BirdsWidgetState();
}

class _BirdsWidgetState extends State<BirdsWidget>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() => _elapsed = elapsed);
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: _BirdFlockPainter(
              elapsed: _elapsed,
              width: c.maxWidth,
              height: c.maxHeight,
            ),
            size: Size(c.maxWidth, c.maxHeight),
          ),
        );
      },
    );
  }
}

class _BirdFlockPainter extends CustomPainter {
  _BirdFlockPainter({
    required this.elapsed,
    required this.width,
    required this.height,
  });

  final Duration elapsed;
  final double width;
  final double height;

  static const double _intervalSec = 12;
  static const double _flightSec = 5.5;

  void _bird(Canvas canvas, Offset center, double wing, Paint paint) {
    final path = Path()
      ..moveTo(center.dx - wing * 0.5, center.dy)
      ..quadraticBezierTo(
        center.dx - wing * 0.12,
        center.dy - wing * 0.22,
        center.dx,
        center.dy - wing * 0.02,
      )
      ..quadraticBezierTo(
        center.dx + wing * 0.12,
        center.dy - wing * 0.22,
        center.dx + wing * 0.5,
        center.dy,
      );
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sec = elapsed.inMicroseconds / 1e6;
    final cycleT = sec % _intervalSec;
    if (cycleT >= _flightSec) return;

    final u = cycleT / _flightSec;
    final ease = u * u * (3 - 2 * u);
    final startX = -width * 0.06;
    final endX = width * 1.06;
    final x = startX + (endX - startX) * ease;

    final baseY = height * 0.28;
    final wing = width * 0.028;

    final paint = Paint()
      ..color = const Color(0xFF2C3A4A).withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, wing * 0.22)
      ..strokeCap = StrokeCap.round;

    final n = 2 + ((sec ~/ _intervalSec) % 2);
    if (n >= 3) {
      _bird(canvas, Offset(x, baseY), wing * 1.05, paint);
      _bird(canvas, Offset(x - width * 0.05, baseY + height * 0.04), wing * 0.9, paint);
      _bird(canvas, Offset(x - width * 0.095, baseY + height * 0.015), wing * 0.85, paint);
    } else {
      _bird(canvas, Offset(x, baseY), wing * 1.05, paint);
      _bird(canvas, Offset(x - width * 0.055, baseY + height * 0.038), wing * 0.88, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BirdFlockPainter oldDelegate) =>
      oldDelegate.elapsed != elapsed ||
      oldDelegate.width != width ||
      oldDelegate.height != height;
}
