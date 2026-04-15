import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Stylized sun: radial core, soft outer halo, no hard edge.
class SunWidget extends StatelessWidget {
  const SunWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SunPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.86, size.height * 0.11);
    final rCore = math.min(size.width, size.height) * 0.072;
    final rHalo = rCore * 2.85;

    final haloRect = Rect.fromCircle(center: c, radius: rHalo);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF8E8).withValues(alpha: 0.42),
          const Color(0xFFFFE4A8).withValues(alpha: 0.22),
          const Color(0xFFFFD27A).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(haloRect);
    canvas.drawCircle(c, rHalo, haloPaint);

    final coreRect = Rect.fromCircle(center: c, radius: rCore * 1.15);
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFCF2),
          const Color(0xFFFFF2C8),
          const Color(0xFFFFE08A).withValues(alpha: 0.85),
          const Color(0xFFFFD078).withValues(alpha: 0.35),
        ],
        stops: const [0.0, 0.35, 0.62, 1.0],
      ).createShader(coreRect);
    canvas.drawCircle(c, rCore * 1.05, corePaint);

    final inner = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          const Color(0xFFFFF6DC).withValues(alpha: 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: rCore * 0.9));
    canvas.drawCircle(c, rCore * 0.88, inner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
