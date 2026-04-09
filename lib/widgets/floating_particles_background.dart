import 'dart:math' as math;

import 'package:flutter/material.dart';

class FloatingParticlesBackground extends StatefulWidget {
  final int particleCount;

  const FloatingParticlesBackground({super.key, this.particleCount = 28});

  @override
  State<FloatingParticlesBackground> createState() =>
      _FloatingParticlesBackgroundState();
}

class _FloatingParticlesBackgroundState
    extends State<FloatingParticlesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_DreamParticle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(93);
    _particles = List.generate(
      widget.particleCount.clamp(20, 40),
      (_) => _DreamParticle.random(rng),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return CustomPaint(
              painter: _FloatingParticlesPainter(
                progress: _controller.value,
                particles: _particles,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _FloatingParticlesPainter extends CustomPainter {
  final double progress;
  final List<_DreamParticle> particles;

  _FloatingParticlesPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()..blendMode = BlendMode.plus;

    for (final p in particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final x =
          (p.baseX + math.sin((t * math.pi * 2) + p.phase) * p.driftX) *
          size.width;
      final y = (1.1 - t) * size.height + p.offsetY * size.height;

      final breathe = 0.85 + 0.15 * math.sin((t * math.pi * 2) + p.phase * 3.0);
      final radius = p.size * breathe;
      final alpha =
          (p.opacity * (0.82 + 0.18 * math.sin((t * math.pi * 2) + p.phase)))
              .clamp(0.03, 0.22);

      final color = p.color.withValues(alpha: alpha);
      glowPaint.color = color;

      if (p.blurSigma > 0) {
        glowPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, p.blurSigma);
      } else {
        glowPaint.maskFilter = null;
      }
      canvas.drawCircle(Offset(x, y), radius, glowPaint);

      if (p.isBokeh) {
        final bokehPaint = Paint()
          ..shader =
              RadialGradient(
                colors: [
                  p.color.withValues(alpha: alpha * 0.65),
                  p.color.withValues(alpha: 0.0),
                ],
              ).createShader(
                Rect.fromCircle(center: Offset(x, y), radius: radius * 2.2),
              );
        canvas.drawCircle(Offset(x, y), radius * 2.2, bokehPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}

class _DreamParticle {
  final double baseX;
  final double offsetY;
  final double size;
  final double opacity;
  final double speed;
  final double phase;
  final double driftX;
  final double blurSigma;
  final bool isBokeh;
  final Color color;

  const _DreamParticle({
    required this.baseX,
    required this.offsetY,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.phase,
    required this.driftX,
    required this.blurSigma,
    required this.isBokeh,
    required this.color,
  });

  factory _DreamParticle.random(math.Random rng) {
    const palette = <Color>[
      Color(0x66FFFFFF),
      Color(0x66C8B7F2),
      Color(0x66D7C8FF),
      Color(0x55EBD9F8),
    ];

    final isBokeh = rng.nextDouble() > 0.65;
    return _DreamParticle(
      baseX: rng.nextDouble(),
      offsetY: (rng.nextDouble() * 0.45) - 0.2,
      size: isBokeh ? 7 + rng.nextDouble() * 12 : 1.8 + rng.nextDouble() * 4.2,
      opacity: isBokeh
          ? 0.12 + rng.nextDouble() * 0.09
          : 0.06 + rng.nextDouble() * 0.08,
      speed: 0.24 + rng.nextDouble() * 0.40,
      phase: rng.nextDouble(),
      driftX: 0.015 + rng.nextDouble() * 0.04,
      blurSigma: isBokeh
          ? 7 + rng.nextDouble() * 7
          : (rng.nextDouble() > 0.6 ? 2.2 : 0),
      isBokeh: isBokeh,
      color: palette[rng.nextInt(palette.length)],
    );
  }
}
