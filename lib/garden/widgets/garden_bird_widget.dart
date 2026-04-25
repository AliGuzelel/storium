import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Bird silhouettes: variable gaps, flock size, speed, and vertical band.
class BirdsWidget extends StatefulWidget {
  const BirdsWidget({super.key});

  @override
  State<BirdsWidget> createState() => _BirdsWidgetState();
}

class _BirdsWidgetState extends State<BirdsWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _elapsed = Duration.zero;

  final math.Random _rng = math.Random();
  double? _flightStartSec;
  double _idleUntilSec = 0;
  double _flightDurationSec = 5.5;
  double _speedMul = 1.0;
  int _birdCount = 2;
  double _baseYFraction = 0.28;
  double _spacingW = 0.055;

  @override
  void initState() {
    super.initState();
    _idleUntilSec = 1.5 + _rng.nextDouble() * 4;
    _ticker = createTicker((elapsed) {
      _advance(elapsed);
      setState(() => _elapsed = elapsed);
    });
    _ticker.start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureTickerRunning());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureTickerRunning();
  }

  void _ensureTickerRunning() {
    if (!mounted) return;
    if (TickerMode.of(context) && !_ticker.isActive) {
      _ticker.start();
    }
  }

  void _advance(Duration elapsed) {
    final sec = elapsed.inMicroseconds / 1e6;

    if (_flightStartSec != null) {
      final effectiveDur = _flightDurationSec / _speedMul;
      if (sec >= _flightStartSec! + effectiveDur) {
        _flightStartSec = null;
        _idleUntilSec = sec + 4 + _rng.nextDouble() * 18;
      }
      return;
    }

    if (sec >= _idleUntilSec) {
      if (_rng.nextDouble() < 0.2) {
        _idleUntilSec = sec + 6 + _rng.nextDouble() * 14;
        return;
      }
      _flightStartSec = sec;
      _flightDurationSec = 4.2 + _rng.nextDouble() * 4.8;
      _speedMul = 0.78 + _rng.nextDouble() * 0.42;
      _birdCount = 2 + _rng.nextInt(2);
      _baseYFraction = 0.18 + _rng.nextDouble() * 0.22;
      _spacingW = 0.042 + _rng.nextDouble() * 0.035;
    }
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
        final sec = _elapsed.inMicroseconds / 1e6;
        double? u;
        if (_flightStartSec != null) {
          final effectiveDur = _flightDurationSec / _speedMul;
          final t = sec - _flightStartSec!;
          if (t >= 0 && t <= effectiveDur) {
            u = (t / effectiveDur).clamp(0.0, 1.0);
          }
        }

        return RepaintBoundary(
          child: CustomPaint(
            painter: _BirdFlockPainter(
              progress: u,
              width: c.maxWidth,
              height: c.maxHeight,
              birdCount: _birdCount,
              baseYFraction: _baseYFraction,
              spacingW: _spacingW,
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
    required this.progress,
    required this.width,
    required this.height,
    required this.birdCount,
    required this.baseYFraction,
    required this.spacingW,
  });

  final double? progress;
  final double width;
  final double height;
  final int birdCount;
  final double baseYFraction;
  final double spacingW;

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
    final u = progress;
    if (u == null) return;

    final ease = u * u * (3 - 2 * u);
    final startX = -width * 0.06;
    final endX = width * 1.06;
    final x = startX + (endX - startX) * ease;

    final baseY = height * baseYFraction;
    final wing = width * 0.028;

    final paint = Paint()
      ..color = const Color(0xFF2C3A4A).withValues(alpha: 0.68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, wing * 0.2)
      ..strokeCap = StrokeCap.round;

    if (birdCount >= 3) {
      _bird(canvas, Offset(x, baseY), wing * 1.05, paint);
      _bird(
        canvas,
        Offset(x - width * spacingW, baseY + height * 0.04),
        wing * 0.9,
        paint,
      );
      _bird(
        canvas,
        Offset(x - width * (spacingW * 1.75), baseY + height * 0.016),
        wing * 0.85,
        paint,
      );
    } else {
      _bird(canvas, Offset(x, baseY), wing * 1.05, paint);
      _bird(
        canvas,
        Offset(x - width * (spacingW * 1.05), baseY + height * 0.038),
        wing * 0.88,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BirdFlockPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.width != width ||
      oldDelegate.height != height ||
      oldDelegate.birdCount != birdCount ||
      oldDelegate.baseYFraction != baseYFraction ||
      oldDelegate.spacingW != spacingW;
}
