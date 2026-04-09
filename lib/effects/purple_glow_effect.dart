import 'dart:math' as math;

import 'package:flutter/material.dart';

class PurpleGlowEffect extends StatefulWidget {
  const PurpleGlowEffect({super.key});

  @override
  State<PurpleGlowEffect> createState() => _PurpleGlowEffectState();
}

class _PurpleGlowEffectState extends State<PurpleGlowEffect>
    with SingleTickerProviderStateMixin {
  static const int _particleCount = 40;

  late final AnimationController _controller;
  late final List<_GlowParticle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(27);
    _particles = List<_GlowParticle>.generate(
      _particleCount,
      (_) => _GlowParticle.random(rng),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
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
              size: Size.infinite,
              painter: _PurpleGlowPainter(
                progress: _controller.value,
                particles: _particles,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PurpleGlowPainter extends CustomPainter {
  const _PurpleGlowPainter({required this.progress, required this.particles});

  final double progress;
  final List<_GlowParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()..blendMode = BlendMode.plus;
    final corePaint = Paint();

    for (final p in particles) {
      final t = (progress * p.speed + p.phase) % 1.0;

      final x =
          (p.baseX + math.sin((t * math.pi * 2) + p.phase) * p.driftX) *
          size.width;
      final y = (1.12 - t) * size.height + p.offsetY * size.height;

      final pulse = p.canPulse
          ? (0.94 + 0.08 * math.sin((t * math.pi * 2) + p.phase * 2.3))
          : 1.0;
      final radius = p.size * pulse;
      final alpha =
          (p.opacity *
                  (0.88 + 0.12 * math.sin((t * math.pi * 2) + p.phase * 1.7)))
              .clamp(0.1, 0.4);

      final color = p.color.withValues(alpha: alpha);

      glowPaint
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.blurSigma);
      canvas.drawCircle(
        Offset(x, y),
        radius * (p.isSoft ? 1.8 : 1.35),
        glowPaint,
      );

      if (!p.isSoft) {
        corePaint.color = color.withValues(
          alpha: (alpha + 0.08).clamp(0.0, 0.45),
        );
        canvas.drawCircle(Offset(x, y), radius, corePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PurpleGlowPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}

class _GlowParticle {
  const _GlowParticle({
    required this.baseX,
    required this.offsetY,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.phase,
    required this.driftX,
    required this.blurSigma,
    required this.isSoft,
    required this.canPulse,
    required this.color,
  });

  final double baseX;
  final double offsetY;
  final double size;
  final double opacity;
  final double speed;
  final double phase;
  final double driftX;
  final double blurSigma;
  final bool isSoft;
  final bool canPulse;
  final Color color;

  factory _GlowParticle.random(math.Random rng) {
    const palette = <Color>[
      Color(0x66FFFFFF),
      Color(0x66DCCFFF),
      Color(0x66C8B7F2),
    ];
    final isSoft = rng.nextDouble() > 0.42;
    return _GlowParticle(
      baseX: rng.nextDouble(),
      offsetY: (rng.nextDouble() * 0.55) - 0.25,
      size: isSoft
          ? 2.8 + rng.nextDouble() * 6.5
          : 1.8 + rng.nextDouble() * 3.2,
      opacity: 0.12 + rng.nextDouble() * 0.24,
      speed: 0.14 + rng.nextDouble() * 0.38,
      phase: rng.nextDouble(),
      driftX: 0.012 + rng.nextDouble() * 0.038,
      blurSigma: isSoft ? 7 + rng.nextDouble() * 8 : 2 + rng.nextDouble() * 3,
      isSoft: isSoft,
      canPulse: rng.nextDouble() > 0.58,
      color: palette[rng.nextInt(palette.length)],
    );
  }
}
