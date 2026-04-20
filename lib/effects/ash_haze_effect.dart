import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/monotonic_seconds_ticker.dart';

class AshHazeEffect extends StatefulWidget {
  const AshHazeEffect({super.key, this.subtle = false});

  final bool subtle;

  @override
  State<AshHazeEffect> createState() => _AshHazeEffectState();
}

class _AshHazeEffectState extends State<AshHazeEffect> {
  static const double _loopSec = 44;
  late List<_HazeBand> _bands;

  void _rebuildBands() {
    _bands = widget.subtle ? _HazeBand.subtleSet : _HazeBand.fullSet;
  }

  @override
  void initState() {
    super.initState();
    _rebuildBands();
  }

  @override
  void didUpdateWidget(covariant AshHazeEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subtle != widget.subtle) {
      _rebuildBands();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: MonotonicSecondsTicker(
          builder: (_, seconds) => CustomPaint(
            size: Size.infinite,
            painter: _AshHazePainter(
              seconds: seconds,
              loopSec: _loopSec,
              subtle: widget.subtle,
              bands: _bands,
            ),
          ),
        ),
      ),
    );
  }
}

class _AshHazePainter extends CustomPainter {
  const _AshHazePainter({
    required this.seconds,
    required this.loopSec,
    required this.subtle,
    required this.bands,
  });

  final double seconds;
  final double loopSec;
  final bool subtle;
  final List<_HazeBand> bands;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBaseWash(canvas, size);
    final t = seconds * (2 * math.pi / loopSec);
    final spreadProgress = 1 - math.exp(-seconds * (subtle ? 0.045 : 0.055));
    _paintCenterCore(canvas, size, t);
    for (final b in bands) {
      final centerX = 0.5 + (b.dirX * b.maxReachX * spreadProgress * 0.52);
      final centerY = 0.5 + (b.dirY * b.maxReachY * spreadProgress * 0.52);
      final x =
          size.width * (centerX + math.sin(t * b.speed + b.phase) * b.driftX);
      final y = size.height *
          (centerY + math.cos(t * b.speed * 0.74 + b.phase * 1.15) * b.driftY);
      final w = size.width * b.widthScale;
      final h = size.height * b.heightScale;

      final rect = Rect.fromCenter(center: Offset(x, y), width: w, height: h);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            b.color.withValues(alpha: b.opacity),
            b.color.withValues(alpha: 0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(rect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, subtle ? 34 : 46);

      canvas.drawOval(rect, paint);
    }
  }

  void _paintCenterCore(Canvas canvas, Size size, double t) {
    final pulse = 0.96 + math.sin(t * 0.2) * 0.04;
    final rect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.5),
      width: size.width * (subtle ? 0.54 : 0.62) * pulse,
      height: size.height * (subtle ? 0.3 : 0.36) * pulse,
    );
    final paint = Paint()
      ..shader = RadialGradient(
        colors: subtle
            ? const [Color(0x33DEDEDE), Color(0x00DEDEDE)]
            : const [Color(0x44D9D9D9), Color(0x00D9D9D9)],
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, subtle ? 32 : 42);
    canvas.drawOval(rect, paint);
  }

  void _paintBaseWash(Canvas canvas, Size size) {
    final wash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: subtle
            ? const [
                Color(0x08FFFFFF),
                Color(0x0CDCDCDC),
                Color(0x10CFCFCF),
                Color(0x08EFEFEF),
              ]
            : const [
                Color(0x10FFFFFF),
                Color(0x16DFDFDF),
                Color(0x1CCFCFCF),
                Color(0x12F1F1F1),
              ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wash);
  }

  @override
  bool shouldRepaint(covariant _AshHazePainter oldDelegate) {
    return oldDelegate.seconds != seconds || oldDelegate.subtle != subtle;
  }
}

class _HazeBand {
  const _HazeBand({
    required this.widthScale,
    required this.heightScale,
    required this.dirX,
    required this.dirY,
    required this.maxReachX,
    required this.maxReachY,
    required this.driftX,
    required this.driftY,
    required this.speed,
    required this.phase,
    required this.opacity,
    required this.color,
  });

  final double widthScale;
  final double heightScale;
  final double dirX;
  final double dirY;
  final double maxReachX;
  final double maxReachY;
  final double driftX;
  final double driftY;
  final double speed;
  final double phase;
  final double opacity;
  final Color color;

  static const List<_HazeBand> fullSet = [
    _HazeBand(
      widthScale: 0.76,
      heightScale: 0.31,
      dirX: -0.9,
      dirY: -0.85,
      maxReachX: 0.44,
      maxReachY: 0.42,
      driftX: 0.03,
      driftY: 0.014,
      speed: 0.27,
      phase: 0.4,
      opacity: 0.15,
      color: Color(0xFFD8D8D8),
    ),
    _HazeBand(
      widthScale: 0.82,
      heightScale: 0.33,
      dirX: 0.95,
      dirY: -0.4,
      maxReachX: 0.43,
      maxReachY: 0.28,
      driftX: 0.028,
      driftY: 0.013,
      speed: 0.235,
      phase: 1.9,
      opacity: 0.14,
      color: Color(0xFFE5E5E5),
    ),
    _HazeBand(
      widthScale: 0.78,
      heightScale: 0.31,
      dirX: -0.55,
      dirY: 0.9,
      maxReachX: 0.32,
      maxReachY: 0.4,
      driftX: 0.03,
      driftY: 0.013,
      speed: 0.21,
      phase: 3.1,
      opacity: 0.13,
      color: Color(0xFFD2D2D2),
    ),
    _HazeBand(
      widthScale: 0.72,
      heightScale: 0.3,
      dirX: 0.6,
      dirY: 0.82,
      maxReachX: 0.34,
      maxReachY: 0.38,
      driftX: 0.026,
      driftY: 0.012,
      speed: 0.245,
      phase: 4.1,
      opacity: 0.125,
      color: Color(0xFFDCDCDC),
    ),
    _HazeBand(
      widthScale: 0.66,
      heightScale: 0.28,
      dirX: 0.08,
      dirY: -0.98,
      maxReachX: 0.08,
      maxReachY: 0.44,
      driftX: 0.022,
      driftY: 0.011,
      speed: 0.2,
      phase: 5.0,
      opacity: 0.12,
      color: Color(0xFFE8E8E8),
    ),
    _HazeBand(
      widthScale: 0.68,
      heightScale: 0.28,
      dirX: -0.98,
      dirY: 0.1,
      maxReachX: 0.44,
      maxReachY: 0.1,
      driftX: 0.022,
      driftY: 0.011,
      speed: 0.195,
      phase: 2.7,
      opacity: 0.118,
      color: Color(0xFFD6D6D6),
    ),
  ];

  static const List<_HazeBand> subtleSet = [
    _HazeBand(
      widthScale: 0.72,
      heightScale: 0.29,
      dirX: -0.9,
      dirY: -0.85,
      maxReachX: 0.38,
      maxReachY: 0.34,
      driftX: 0.024,
      driftY: 0.011,
      speed: 0.22,
      phase: 0.6,
      opacity: 0.115,
      color: Color(0xFFDCDCDC),
    ),
    _HazeBand(
      widthScale: 0.76,
      heightScale: 0.3,
      dirX: 0.88,
      dirY: 0.75,
      maxReachX: 0.37,
      maxReachY: 0.33,
      driftX: 0.022,
      driftY: 0.01,
      speed: 0.195,
      phase: 2.2,
      opacity: 0.11,
      color: Color(0xFFE6E6E6),
    ),
    _HazeBand(
      widthScale: 0.66,
      heightScale: 0.27,
      dirX: 0.14,
      dirY: -1.0,
      maxReachX: 0.09,
      maxReachY: 0.4,
      driftX: 0.02,
      driftY: 0.009,
      speed: 0.185,
      phase: 4.0,
      opacity: 0.105,
      color: Color(0xFFDDDDDD),
    ),
    _HazeBand(
      widthScale: 0.64,
      heightScale: 0.26,
      dirX: -1.0,
      dirY: 0.12,
      maxReachX: 0.4,
      maxReachY: 0.08,
      driftX: 0.019,
      driftY: 0.009,
      speed: 0.18,
      phase: 1.8,
      opacity: 0.102,
      color: Color(0xFFD8D8D8),
    ),
  ];
}
