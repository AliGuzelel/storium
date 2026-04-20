import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/monotonic_seconds_ticker.dart';

class CherryFloatEffect extends StatefulWidget {
  const CherryFloatEffect({super.key, this.subtle = false});

  final bool subtle;

  @override
  State<CherryFloatEffect> createState() => _CherryFloatEffectState();
}

class _CherryFloatEffectState extends State<CherryFloatEffect> {
  static const double _loopSec = 20;
  late List<_CherrySprite> _sprites;

  void _rebuildSprites() {
    _sprites = widget.subtle ? _CherrySprite.subtleSet : _CherrySprite.fullSet;
  }

  @override
  void initState() {
    super.initState();
    _rebuildSprites();
  }

  @override
  void didUpdateWidget(covariant CherryFloatEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subtle != widget.subtle) {
      _rebuildSprites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: MonotonicSecondsTicker(
          builder: (_, seconds) => CustomPaint(
            size: Size.infinite,
            painter: _CherryFloatPainter(
              seconds: seconds,
              loopSec: _loopSec,
              sprites: _sprites,
              subtle: widget.subtle,
            ),
          ),
        ),
      ),
    );
  }
}

class _CherryFloatPainter extends CustomPainter {
  const _CherryFloatPainter({
    required this.seconds,
    required this.loopSec,
    required this.sprites,
    required this.subtle,
  });

  final double seconds;
  final double loopSec;
  final List<_CherrySprite> sprites;
  final bool subtle;

  @override
  void paint(Canvas canvas, Size size) {
    final cycle = seconds * (2 * math.pi / loopSec);
    for (final s in sprites) {
      final wanderX = math.sin(cycle * (0.82 + s.speed * 0.32) + s.phase) * s.floatX +
          math.sin(cycle * (1.73 + s.speed * 0.22) + s.phase * 1.7) * (s.floatX * 0.68);
      final wanderY = math.cos(cycle * (0.74 + s.speed * 0.28) + s.phase * 1.1) * s.floatY +
          math.sin(cycle * (1.57 + s.speed * 0.2) + s.phase * 1.9) * (s.floatY * 0.64);
      final radiusPx = s.size * (subtle ? 0.9 : 1.0);
      final edgeMarginX = ((radiusPx * 1.6) / size.width).clamp(0.02, 0.14);
      final edgeMarginY = ((radiusPx * 2.3) / size.height).clamp(0.03, 0.2);
      final xNorm = _reflectBetween(
        s.baseX + (seconds * s.travelSpeedX) + wanderX,
        edgeMarginX,
        1 - edgeMarginX,
      );
      final yNorm = _reflectBetween(
        s.baseY + (seconds * s.travelSpeedY) + wanderY,
        edgeMarginY,
        1 - edgeMarginY,
      );

      final center = Offset(
        xNorm * size.width,
        yNorm * size.height,
      );
      _drawCherryPair(canvas, center, s, subtle);
    }
  }

  double _reflectBetween(double value, double min, double max) {
    final span = max - min;
    if (span <= 0) return min;
    final shifted = value - min;
    final twoSpan = span * 2;
    var local = shifted % twoSpan;
    if (local < 0) local += twoSpan;
    if (local > span) {
      local = twoSpan - local;
    }
    return min + local;
  }

  void _drawCherryPair(Canvas canvas, Offset center, _CherrySprite sprite, bool subtleMode) {
    final opacityScale = subtleMode ? 0.72 : 1.0;
    final berryRadius = sprite.size * (subtleMode ? 0.9 : 1.0);

    final left = Offset(center.dx - berryRadius * 0.62, center.dy + berryRadius * 0.32);
    final right = Offset(center.dx + berryRadius * 0.62, center.dy + berryRadius * 0.32);
    final stemTop = Offset(center.dx, center.dy - berryRadius * 1.85);

    final stemPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = berryRadius * 0.16
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF6F8A55).withValues(alpha: (0.9 * opacityScale).clamp(0.0, 1.0));

    final stemPath = Path()
      ..moveTo(stemTop.dx, stemTop.dy)
      ..quadraticBezierTo(center.dx - berryRadius * 0.65, center.dy - berryRadius * 0.48, left.dx, left.dy - berryRadius * 0.86)
      ..moveTo(stemTop.dx, stemTop.dy)
      ..quadraticBezierTo(center.dx + berryRadius * 0.65, center.dy - berryRadius * 0.48, right.dx, right.dy - berryRadius * 0.86);
    canvas.drawPath(stemPath, stemPaint);

    final leafPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF9CCB84).withValues(alpha: (0.8 * opacityScale).clamp(0.0, 1.0));
    final leafPath = Path()
      ..moveTo(stemTop.dx, stemTop.dy)
      ..quadraticBezierTo(stemTop.dx - berryRadius * 0.6, stemTop.dy - berryRadius * 0.18, stemTop.dx - berryRadius * 0.1, stemTop.dy - berryRadius * 0.46)
      ..quadraticBezierTo(stemTop.dx + berryRadius * 0.16, stemTop.dy - berryRadius * 0.3, stemTop.dx, stemTop.dy);
    canvas.drawPath(leafPath, leafPaint);

    _drawBerry(canvas, left, berryRadius, sprite.tint, opacityScale);
    _drawBerry(canvas, right, berryRadius, sprite.tint, opacityScale);
  }

  void _drawBerry(Canvas canvas, Offset center, double radius, Color tint, double opacityScale) {
    final berryRect = Rect.fromCircle(center: center, radius: radius);
    final berryPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.42),
        radius: 1.0,
        colors: [
          Color.lerp(const Color(0xFFFFA6C0), tint, 0.2)!.withValues(alpha: (0.95 * opacityScale).clamp(0.0, 1.0)),
          tint.withValues(alpha: (0.98 * opacityScale).clamp(0.0, 1.0)),
          Color.lerp(tint, const Color(0xFF5A1118), 0.38)!.withValues(alpha: (0.98 * opacityScale).clamp(0.0, 1.0)),
        ],
      ).createShader(berryRect);
    canvas.drawCircle(center, radius, berryPaint);

    final shinePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: (0.38 * opacityScale).clamp(0.0, 1.0));
    canvas.drawCircle(Offset(center.dx - radius * 0.34, center.dy - radius * 0.36), radius * 0.28, shinePaint);
  }

  @override
  bool shouldRepaint(covariant _CherryFloatPainter oldDelegate) {
    return oldDelegate.seconds != seconds || oldDelegate.subtle != subtle;
  }
}

class _CherrySprite {
  const _CherrySprite({
    required this.baseX,
    required this.baseY,
    required this.size,
    required this.floatX,
    required this.floatY,
    required this.speed,
    required this.travelSpeedX,
    required this.travelSpeedY,
    required this.phase,
    required this.tint,
  });

  final double baseX;
  final double baseY;
  final double size;
  final double floatX;
  final double floatY;
  final double speed;
  final double travelSpeedX;
  final double travelSpeedY;
  final double phase;
  final Color tint;

  static const List<_CherrySprite> fullSet = [
    _CherrySprite(baseX: 0.18, baseY: 0.24, size: 10, floatX: 0.011, floatY: 0.009, speed: 0.38, travelSpeedX: 0.024, travelSpeedY: -0.013, phase: 0.1, tint: Color(0xFFE0445A)),
    _CherrySprite(baseX: 0.78, baseY: 0.2, size: 11, floatX: 0.012, floatY: 0.01, speed: 0.34, travelSpeedX: -0.022, travelSpeedY: 0.014, phase: 1.4, tint: Color(0xFFDB3A51)),
    _CherrySprite(baseX: 0.12, baseY: 0.68, size: 12, floatX: 0.013, floatY: 0.011, speed: 0.31, travelSpeedX: 0.02, travelSpeedY: -0.011, phase: 2.3, tint: Color(0xFFD8334D)),
    _CherrySprite(baseX: 0.86, baseY: 0.66, size: 10, floatX: 0.01, floatY: 0.009, speed: 0.36, travelSpeedX: -0.019, travelSpeedY: 0.012, phase: 3.5, tint: Color(0xFFD62E49)),
    _CherrySprite(baseX: 0.52, baseY: 0.3, size: 9.5, floatX: 0.009, floatY: 0.008, speed: 0.4, travelSpeedX: 0.018, travelSpeedY: 0.01, phase: 2.7, tint: Color(0xFFE54B62)),
    _CherrySprite(baseX: 0.48, baseY: 0.74, size: 11, floatX: 0.012, floatY: 0.01, speed: 0.29, travelSpeedX: -0.018, travelSpeedY: -0.012, phase: 4.2, tint: Color(0xFFDF4058)),
    _CherrySprite(baseX: 0.34, baseY: 0.16, size: 9.5, floatX: 0.009, floatY: 0.008, speed: 0.35, travelSpeedX: 0.017, travelSpeedY: 0.011, phase: 5.1, tint: Color(0xFFE04961)),
    _CherrySprite(baseX: 0.68, baseY: 0.82, size: 10, floatX: 0.01, floatY: 0.009, speed: 0.3, travelSpeedX: -0.017, travelSpeedY: -0.01, phase: 0.9, tint: Color(0xFFDA3C55)),
  ];

  static const List<_CherrySprite> subtleSet = [
    _CherrySprite(baseX: 0.2, baseY: 0.24, size: 9.5, floatX: 0.009, floatY: 0.007, speed: 0.35, travelSpeedX: 0.018, travelSpeedY: -0.01, phase: 0.5, tint: Color(0xFFE2475C)),
    _CherrySprite(baseX: 0.8, baseY: 0.22, size: 10, floatX: 0.01, floatY: 0.008, speed: 0.32, travelSpeedX: -0.017, travelSpeedY: 0.01, phase: 1.6, tint: Color(0xFFDA3951)),
    _CherrySprite(baseX: 0.16, baseY: 0.7, size: 10, floatX: 0.01, floatY: 0.009, speed: 0.3, travelSpeedX: 0.016, travelSpeedY: -0.009, phase: 2.8, tint: Color(0xFFD5324C)),
    _CherrySprite(baseX: 0.82, baseY: 0.68, size: 9.5, floatX: 0.009, floatY: 0.008, speed: 0.34, travelSpeedX: -0.016, travelSpeedY: 0.008, phase: 3.9, tint: Color(0xFFDA3F56)),
    _CherrySprite(baseX: 0.5, baseY: 0.5, size: 9, floatX: 0.008, floatY: 0.007, speed: 0.31, travelSpeedX: 0.015, travelSpeedY: -0.008, phase: 4.7, tint: Color(0xFFDF445B)),
  ];
}
