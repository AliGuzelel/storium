import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Raster soil tile for the garden lower panel.
const String kGardenSoilImageAsset = 'assets/images/plants/soil.png';

/// Tufts of blades (clusters) with varied greens; reads more like real turf edge.
class GardenGrassStripPainter extends CustomPainter {
  GardenGrassStripPainter({
    required this.windPhase,
    this.seed = 11,
  });

  /// Radians; slow drift for a light breeze.
  final double windPhase;
  final int seed;

  static const _greens = [
    Color(0xFF1B4D2E),
    Color(0xFF245A36),
    Color(0xFF2F6E42),
    Color(0xFF3D8F52),
    Color(0xFF4A9D5C),
  ];

  void _blade(
    Canvas canvas,
    double x0,
    double baseY,
    double height,
    double lean,
    Color color,
    double strokeW,
    double wind,
  ) {
    final midX = x0 + lean * 0.35 + wind * 0.4;
    final tipX = x0 + lean + wind * 0.9;
    final path = Path()
      ..moveTo(x0, baseY)
      ..cubicTo(
        x0 + lean * 0.15,
        baseY - height * 0.35,
        midX,
        baseY - height * 0.72,
        tipX,
        baseY - height,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rng = math.Random(seed);
    final baseY = size.height;
    final tufts = (size.width / 14).round().clamp(18, 56);

    for (var t = 0; t < tufts; t++) {
      final fx = (t + 0.35 + (rng.nextDouble() - 0.5) * 0.12) / tufts;
      final cx = fx * size.width;
      final wind =
          math.sin(windPhase + fx * 8.5 + rng.nextDouble() * 0.8) * 1.15;
      final blades = 4 + rng.nextInt(4);
      for (var b = 0; b < blades; b++) {
        final spread = (b / blades - 0.5) * 5.5;
        final x0 = cx + spread + (rng.nextDouble() - 0.5) * 1.2;
        final h = 14 + rng.nextDouble() * 22;
        final lean = (rng.nextDouble() - 0.4) * 4.2 + wind * 2.1;
        final c = _greens[rng.nextInt(_greens.length)].withValues(
          alpha: 0.52 + rng.nextDouble() * 0.38,
        );
        final sw = 0.85 + rng.nextDouble() * 0.55;
        _blade(canvas, x0, baseY, h, lean, c, sw, wind);
      }
      if (rng.nextDouble() < 0.55) {
        final h2 = 10 + rng.nextDouble() * 14;
        final lean2 = (rng.nextDouble() - 0.5) * 3 + wind;
        _blade(
          canvas,
          cx + (rng.nextDouble() - 0.5) * 3,
          baseY,
          h2,
          lean2,
          const Color(0xFF7BC87A).withValues(alpha: 0.28),
          0.55,
          wind * 0.85,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GardenGrassStripPainter oldDelegate) =>
      oldDelegate.windPhase != windPhase || oldDelegate.seed != seed;
}
