import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


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
              timeSec: sec,
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
    required this.timeSec,
    required this.width,
    required this.height,
    required this.birdCount,
    required this.baseYFraction,
    required this.spacingW,
  });

  final double? progress;
  final double timeSec;
  final double width;
  final double height;
  final int birdCount;
  final double baseYFraction;
  final double spacingW;

  /// Symmetric “flying V”: wing tips move up/down together (one continuous stroke).
  void _bird(
    Canvas canvas,
    Offset center,
    double wing,
    Paint paint,
    double beat,
  ) {
    final tipY = center.dy + wing * 0.16 * beat;
    final shoulderY = center.dy - wing * 0.07;
    final path = Path()
      ..moveTo(center.dx - wing * 0.52, tipY)
      ..quadraticBezierTo(
        center.dx - wing * 0.2,
        shoulderY,
        center.dx,
        center.dy - wing * 0.05,
      )
      ..quadraticBezierTo(
        center.dx + wing * 0.2,
        shoulderY,
        center.dx + wing * 0.52,
        tipY,
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
    // ~1.5 full wing cycles per second (calm; use 2.0 for the top of your range).
    const flapsPerSecond = 1.5;
    final beat = math.sin(timeSec * math.pi * 2 * flapsPerSecond);

    final outline = Paint()
      ..color = const Color(0xFF1E2A38).withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.05, wing * 0.22)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (birdCount >= 3) {
      _bird(canvas, Offset(x, baseY), wing * 1.08, outline, beat);
      _bird(
        canvas,
        Offset(x - width * spacingW, baseY + height * 0.04),
        wing * 0.92,
        outline,
        beat,
      );
      _bird(
        canvas,
        Offset(x - width * (spacingW * 1.75), baseY + height * 0.016),
        wing * 0.86,
        outline,
        beat,
      );
    } else {
      _bird(canvas, Offset(x, baseY), wing * 1.08, outline, beat);
      _bird(
        canvas,
        Offset(x - width * (spacingW * 1.05), baseY + height * 0.038),
        wing * 0.9,
        outline,
        beat,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BirdFlockPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.timeSec != timeSec ||
      oldDelegate.width != width ||
      oldDelegate.height != height ||
      oldDelegate.birdCount != birdCount ||
      oldDelegate.baseYFraction != baseYFraction ||
      oldDelegate.spacingW != spacingW;
}
