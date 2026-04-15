import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum ParticleShape { circle, petal, leaf, blob, ring }

class BaseParticleEffect extends StatefulWidget {
  const BaseParticleEffect({
    super.key,
    required this.seed,
    required this.shape,
    required this.palette,
    this.enableRotation = false,
    this.enableSway = false,
    this.blurStrength = 2,
    this.haloColor,
    this.drawHalo = false,
    this.drawGrainOverlay = false,
    this.strokeShape = false,
    this.sizeMultiplier = 1.0,
    this.opacityMultiplier = 1.0,
  });

  final int seed;
  final ParticleShape shape;
  final List<Color> palette;
  final bool enableRotation;
  final bool enableSway;
  final double blurStrength;
  final Color? haloColor;
  final bool drawHalo;
  final bool drawGrainOverlay;
  final bool strokeShape;
  final double sizeMultiplier;
  final double opacityMultiplier;

  @override
  State<BaseParticleEffect> createState() => _BaseParticleEffectState();
}

class _BaseParticleEffectState extends State<BaseParticleEffect>
    with SingleTickerProviderStateMixin {
  static const int _count = 22;

  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = math.Random(widget.seed);
    _particles = List<_Particle>.generate(_count, (_) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 1.8 + random.nextDouble() * 3.8,
        alpha: 0.015 + random.nextDouble() * 0.05,
        drift: 4 + random.nextDouble() * 12,
        speed: 0.05 + random.nextDouble() * 0.16,
        blur: random.nextBool(),
      );
    });

    _ticker = createTicker((dt) {
      _elapsed += dt;
      setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double get _seconds => _elapsed.inMicroseconds / 1e6;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _BaseParticlePainter(
            seconds: _seconds,
            particles: _particles,
            config: widget,
          ),
        ),
      ),
    );
  }
}

class _BaseParticlePainter extends CustomPainter {
  const _BaseParticlePainter({
    required this.seconds,
    required this.particles,
    required this.config,
  });

  /// Monotonically increasing — avoids phase jumps from repeating0→1 loops.
  final double seconds;
  final List<_Particle> particles;
  final BaseParticleEffect config;

  @override
  void paint(Canvas canvas, Size size) {
    if (config.drawHalo) {
      _paintHalo(canvas, size);
    }

    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final phase = (seconds * 0.22 * p.speed * 2 * math.pi) + i * 0.31;
      var x = (p.x * size.width) + math.sin(phase) * p.drift;
      final y =
          (p.y * size.height) + math.cos(phase * 0.7) * (p.drift * 0.45);
      if (config.enableSway) {
        x += math.sin(seconds * 0.45 * 2 * math.pi + i * 0.8) *
            (p.drift * 0.35);
      }

      final breathe = 0.86 + ((math.sin(phase * 0.65) + 1) / 2) * 0.28;
      final radius = p.radius * breathe * config.sizeMultiplier;
      final color = config.palette[i % config.palette.length].withValues(
        alpha: (p.alpha * config.opacityMultiplier).clamp(0.0, 1.0),
      );

      canvas.save();
      canvas.translate(x, y);
      if (config.enableRotation) {
        canvas.rotate((phase * 0.22) + (math.sin(phase) * 0.18));
      }
      _drawShape(canvas, radius, color, p.blur);
      canvas.restore();
    }

    if (config.drawGrainOverlay) {
      _paintGrain(canvas, size);
    }
  }

  void _paintHalo(Canvas canvas, Size size) {
    final haloCenters = <Offset>[
      Offset(size.width * 0.2, size.height * 0.22),
      Offset(size.width * 0.82, size.height * 0.36),
      Offset(size.width * 0.46, size.height * 0.78),
    ];
    final haloSizes = <double>[
      size.shortestSide * 0.26,
      size.shortestSide * 0.22,
      size.shortestSide * 0.28,
    ];
    for (var i = 0; i < haloCenters.length; i++) {
      final phase =
          (math.sin((seconds * 0.12 + i * 0.17) * 2 * math.pi) + 1) / 2;
      final haloPaint = Paint()
        ..color = (config.haloColor ?? const Color(0xFFCFA8FF)).withValues(
          alpha: 0.025 + phase * 0.025,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 52);
      canvas.drawCircle(
        haloCenters[i],
        haloSizes[i] * (0.92 + phase * 0.12),
        haloPaint,
      );
    }
  }

  void _paintGrain(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const density = 180;
    final phase = (seconds * 3.2).floor();
    for (var i = 0; i < density; i++) {
      final xSeed = ((i * 97 + phase * 13) % 1000) / 1000.0;
      final ySeed = ((i * 57 + phase * 17) % 1000) / 1000.0;
      paint.color = Colors.white.withValues(
        alpha: 0.008 + ((i * 11) % 7) / 1000.0,
      );
      final d = 0.75 + math.sin(i.toDouble()) * 0.2;
      canvas.drawRect(
        Rect.fromLTWH(xSeed * size.width, ySeed * size.height, d, d),
        paint,
      );
    }
  }

  void _drawShape(Canvas canvas, double radius, Color color, bool isBlurred) {
    final paint = Paint()
      ..color = color
      ..style = config.strokeShape ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = config.strokeShape ? 1.15 : 0
      ..maskFilter = isBlurred
          ? MaskFilter.blur(BlurStyle.normal, config.blurStrength)
          : null;

    switch (config.shape) {
      case ParticleShape.circle:
        canvas.drawCircle(Offset.zero, radius, paint);
        break;
      case ParticleShape.petal:
        final path = Path()
          ..moveTo(0, -radius * 1.1)
          ..quadraticBezierTo(
            radius * 1.2,
            -radius * 0.3,
            radius * 0.65,
            radius * 1.0,
          )
          ..quadraticBezierTo(0, radius * 1.45, -radius * 0.65, radius * 1.0)
          ..quadraticBezierTo(-radius * 1.2, -radius * 0.3, 0, -radius * 1.1)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ParticleShape.leaf:
        final path = Path()
          ..moveTo(0, -radius * 1.0)
          ..quadraticBezierTo(radius * 1.2, 0, 0, radius * 1.25)
          ..quadraticBezierTo(-radius * 1.2, 0, 0, -radius * 1.0)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ParticleShape.blob:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 2.4,
            height: radius * 1.6,
          ),
          paint,
        );
        break;
      case ParticleShape.ring:
        canvas.drawCircle(Offset.zero, radius * 1.5, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BaseParticlePainter oldDelegate) =>
      oldDelegate.seconds != seconds || oldDelegate.config != config;
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.alpha,
    required this.drift,
    required this.speed,
    required this.blur,
  });

  final double x;
  final double y;
  final double radius;
  final double alpha;
  final double drift;
  final double speed;
  final bool blur;
}
