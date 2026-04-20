import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/monotonic_seconds_ticker.dart';

class PurpleGlowEffect extends StatefulWidget {
  const PurpleGlowEffect({super.key, this.subtle = false});

  final bool subtle;

  @override
  State<PurpleGlowEffect> createState() => _PurpleGlowEffectState();
}

class _PurpleGlowEffectState extends State<PurpleGlowEffect> {
  static const int _particleCountFull = 40;
  static const int _particleCountSubtle = 14;
  static const double _loopSec = 16;

  late List<_GlowParticle> _particles;

  void _rebuildParticles() {
    final rng = math.Random(27);
    final n = widget.subtle ? _particleCountSubtle : _particleCountFull;
    _particles = List<_GlowParticle>.generate(
      n,
      (_) => _GlowParticle.random(rng, subtle: widget.subtle),
    );
  }

  @override
  void initState() {
    super.initState();
    _rebuildParticles();
  }

  @override
  void didUpdateWidget(covariant PurpleGlowEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subtle != widget.subtle) {
      _rebuildParticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: MonotonicSecondsTicker(
          builder: (_, seconds) {
            return CustomPaint(
              size: Size.infinite,
              painter: _PurpleGlowPainter(
                phase: seconds / _loopSec,
                particles: _particles,
                subtle: widget.subtle,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PurpleGlowPainter extends CustomPainter {
  const _PurpleGlowPainter({
    required this.phase,
    required this.particles,
    required this.subtle,
  });

  final double phase;
  final List<_GlowParticle> particles;
  final bool subtle;

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()..blendMode = BlendMode.plus;
    final corePaint = Paint();
    final m = subtle ? 0.62 : 1.0;
    final alphaCap = subtle ? 0.22 : 0.4;

    for (final p in particles) {
      final t = (phase * p.speed + p.phase) % 1.0;

      final x =
          (p.baseX + math.sin((t * math.pi * 2) + p.phase) * p.driftX * m) *
          size.width;
      final y = (1.12 - t) * size.height + p.offsetY * size.height;

      final pulse = p.canPulse
          ? (0.94 + 0.08 * math.sin((t * math.pi * 2) + p.phase * 2.3))
          : 1.0;
      final radius = p.size * pulse * (subtle ? 0.88 : 1.0);
      final alpha =
          (p.opacity *
                  (0.88 + 0.12 * math.sin((t * math.pi * 2) + p.phase * 1.7)))
              .clamp(0.06, alphaCap);

      final color = p.color.withValues(alpha: alpha);

      glowPaint
        ..color = color
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, p.blurSigma * (subtle ? 0.78 : 1.0));
      canvas.drawCircle(
        Offset(x, y),
        radius * (p.isSoft ? 1.8 : 1.35),
        glowPaint,
      );

      if (!p.isSoft) {
        corePaint.color = color.withValues(
          alpha: (alpha + (subtle ? 0.04 : 0.08)).clamp(0.0, subtle ? 0.22 : 0.45),
        );
        canvas.drawCircle(Offset(x, y), radius, corePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PurpleGlowPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.particles != particles ||
        oldDelegate.subtle != subtle;
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

  factory _GlowParticle.random(math.Random rng, {bool subtle = false}) {
    const palette = <Color>[
      Color(0x66FFFFFF),
      Color(0x66DCCFFF),
      Color(0x66C8B7F2),
    ];
    final isSoft = rng.nextDouble() > 0.42;
    final sp = subtle ? 0.9 : 1.0;
    return _GlowParticle(
      baseX: rng.nextDouble(),
      offsetY: (rng.nextDouble() * 0.55) - 0.25,
      size: (isSoft
              ? 2.8 + rng.nextDouble() * 6.5
              : 1.8 + rng.nextDouble() * 3.2) *
          (subtle ? 0.82 : 1.0),
      opacity: (0.12 + rng.nextDouble() * 0.24) * (subtle ? 0.72 : 1.0),
      speed: (0.14 + rng.nextDouble() * 0.38) * sp,
      phase: rng.nextDouble(),
      driftX: 0.012 + rng.nextDouble() * 0.038,
      blurSigma: isSoft ? 7 + rng.nextDouble() * 8 : 2 + rng.nextDouble() * 3,
      isSoft: isSoft,
      canPulse: rng.nextDouble() > 0.58,
      color: palette[rng.nextInt(palette.length)],
    );
  }
}
