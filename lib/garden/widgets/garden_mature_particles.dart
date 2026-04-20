import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Very subtle drifting specks for fully grown plants (phase 3).
class GardenMatureParticlesPainter extends CustomPainter {
  GardenMatureParticlesPainter({
    required this.seconds,
    required this.accent,
  });

  /// Monotonic time (no AnimationController loop restarts).
  final double seconds;
  final Color accent;

  static const int _n = 9;
  static const double _loopSec = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height * 0.72;
    final p = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    final cycles = seconds / _loopSec;

    for (var i = 0; i < _n; i++) {
      final t = (cycles + i * 0.11) % 1.0;
      final ang = i * 1.7 + seconds * (2 * math.pi / _loopSec);
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
      oldDelegate.seconds != seconds || oldDelegate.accent != accent;
}
