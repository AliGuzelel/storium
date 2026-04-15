import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Very subtle drifting specks for fully grown plants (phase 3).
class GardenMatureParticlesPainter extends CustomPainter {
  GardenMatureParticlesPainter({
    required this.progress,
    required this.accent,
  });

  final double progress;
  final Color accent;

  static const int _n = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height * 0.72;
    final p = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

    for (var i = 0; i < _n; i++) {
      final t = (progress + i * 0.11) % 1.0;
      final ang = i * 1.7 + progress * math.pi * 2;
      final r = 8.0 + (i % 4) * 5.0;
      final ox = math.cos(ang) * r * 0.35;
      final oy = -t * 42 - (i % 3) * 6.0;
      final a = 0.06 * (1 - t) * (0.6 + 0.4 * math.sin(ang * 2));
      final pr = 1.2 + (i % 3) * 0.35;
      canvas.drawCircle(
        Offset(cx + ox, baseY + oy),
        pr,
        p..color = accent.withValues(alpha: a.clamp(0.02, 0.09)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GardenMatureParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}
