import 'dart:math' as math;

import 'package:flutter/material.dart';

class CherryBlossomEffect extends StatefulWidget {
  const CherryBlossomEffect({super.key});

  @override
  State<CherryBlossomEffect> createState() => _CherryBlossomEffectState();
}

class _CherryBlossomEffectState extends State<CherryBlossomEffect>
    with SingleTickerProviderStateMixin {
  static const int _particleCount = 56;

  late final AnimationController _controller;
  late final List<_PetalParticle> _petals;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(27);
    _petals = List<_PetalParticle>.generate(
      _particleCount,
      (_) => _PetalParticle.random(rng),
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
              painter: _CherryBlossomPainter(
                progress: _controller.value,
                petals: _petals,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CherryBlossomPainter extends CustomPainter {
  const _CherryBlossomPainter({required this.progress, required this.petals});

  final double progress;
  final List<_PetalParticle> petals;

  @override
  void paint(Canvas canvas, Size size) {
    final petalPaint = Paint();

    for (final p in petals) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final time = progress * math.pi * 2;
      final windShift = math.sin((time * 0.14) + p.windOffset * 0.7);
      final horizontalWind =
          math.sin((time * 0.5) + p.windOffset) *
          (p.windStrength + windShift * 0.0025);
      final sway =
          math.sin((time * 0.3) + p.windOffset) * (p.windStrength * 0.72);
      final wobble =
          math.sin((time * p.wobbleSpeed) + p.phase * 2.1) * p.wobbleAmp;
      final driftWave = math.sin((t * math.pi * 2) + p.phase) * p.driftX;
      final x =
          (p.baseX + driftWave + horizontalWind + sway + wobble) * size.width;

      final yBase = (t * 1.15) * size.height + p.offsetY * size.height;
      final fallVariation =
          math.sin(time + p.windOffset) * (0.3 * size.height * 0.0065);
      final y = yBase + fallVariation;
      final pulse = p.canPulse
          ? (0.94 + 0.08 * math.sin((t * math.pi * 2) + p.phase * 2.3))
          : 1.0;
      final radius = p.size * pulse;
      final alpha =
          (p.opacity *
                  (0.88 + 0.12 * math.sin((t * math.pi * 2) + p.phase * 1.7)))
              .clamp(0.2, 0.6);

      final rotation =
          p.rotationSeed + (t * 2 * math.pi * p.rotationSpeed * p.rotationDir);
      final petalSize = radius * 2;
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: petalSize,
        height: petalSize,
      );

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      petalPaint
        ..style = PaintingStyle.fill
        ..shader = const RadialGradient(
          colors: [Color(0xFFF9CCD9), Color(0xFFE88FAA)],
        ).createShader(rect)
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = null;
      canvas.drawPath(createPetalPath(petalSize), petalPaint);

      // Soft inner highlight to make the shape read closer to sakura artwork.
      final detailPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(
          alpha: (alpha * 0.22).clamp(0.06, 0.16),
        );
      canvas.drawPath(createInnerPetalPath(petalSize * 0.72), detailPaint);
      canvas.restore();
    }
  }

  Path createPetalPath(double size) {
    final path = Path();
    final half = size * 0.5;
    final notch = size * 0.1;

    path.moveTo(0, -half + notch);
    path.quadraticBezierTo(size * 0.08, -half, size * 0.2, -half + notch * 0.2);
    path.quadraticBezierTo(size * 0.4, -size * 0.25, size * 0.34, size * 0.12);
    path.quadraticBezierTo(size * 0.24, size * 0.46, size * 0.02, size * 0.58);
    path.quadraticBezierTo(0, size * 0.62, -size * 0.02, size * 0.58);
    path.quadraticBezierTo(
      -size * 0.24,
      size * 0.46,
      -size * 0.34,
      size * 0.12,
    );
    path.quadraticBezierTo(
      -size * 0.4,
      -size * 0.25,
      -size * 0.2,
      -half + notch * 0.2,
    );
    path.quadraticBezierTo(-size * 0.08, -half, 0, -half + notch);
    path.close();

    return path;
  }

  Path createInnerPetalPath(double size) {
    final path = Path();
    final half = size * 0.5;

    path.moveTo(0, -half + size * 0.12);
    path.quadraticBezierTo(size * 0.2, -size * 0.22, size * 0.2, size * 0.14);
    path.quadraticBezierTo(0, size * 0.4, -size * 0.2, size * 0.14);
    path.quadraticBezierTo(-size * 0.2, -size * 0.22, 0, -half + size * 0.12);

    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant _CherryBlossomPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.petals != petals;
  }
}

class _PetalParticle {
  const _PetalParticle({
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
    required this.rotationSeed,
    required this.rotationSpeed,
    required this.rotationDir,
    required this.wobbleAmp,
    required this.wobbleSpeed,
    required this.windStrength,
    required this.windOffset,
    required this.shapeBias,
    required this.color,
    required this.centerColor,
    required this.edgeColor,
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
  final double rotationSeed;
  final double rotationSpeed;
  final double rotationDir;
  final double wobbleAmp;
  final double wobbleSpeed;
  final double windStrength;
  final double windOffset;
  final double shapeBias;
  final Color color;
  final Color centerColor;
  final Color edgeColor;

  factory _PetalParticle.random(math.Random rng) {
    const palette = <Color>[
      Color(0x66FFF7FA),
      Color(0x66F5D6E4),
      Color(0x66F8DCE7),
    ];
    const centerPalette = <Color>[
      Color(0x80FFF9FC),
      Color(0x80FFEFF6),
      Color(0x80FBEAF4),
    ];
    const edgePalette = <Color>[
      Color(0x66E7C6D8),
      Color(0x66DDB7CD),
      Color(0x66D9B7D6),
    ];
    final depthRoll = rng.nextDouble();
    final isLarge = depthRoll > 0.82;
    final isSmall = depthRoll < 0.28;
    final isMedium = !isLarge && !isSmall;
    final isSoft = rng.nextDouble() > 0.42;

    final size = isLarge
        ? 13 + rng.nextDouble() * 6
        : isMedium
        ? 9 + rng.nextDouble() * 5
        : 7 + rng.nextDouble() * 3;
    final opacity = isLarge
        ? 0.38 + rng.nextDouble() * 0.22
        : isMedium
        ? 0.28 + rng.nextDouble() * 0.22
        : 0.2 + rng.nextDouble() * 0.18;
    final speed = isLarge
        ? 0.3 + rng.nextDouble() * 0.22
        : isMedium
        ? 0.2 + rng.nextDouble() * 0.22
        : 0.14 + rng.nextDouble() * 0.18;

    return _PetalParticle(
      baseX: rng.nextDouble(),
      offsetY: (rng.nextDouble() * 0.55) - 0.32,
      size: size,
      opacity: opacity,
      speed: speed,
      phase: rng.nextDouble(),
      driftX: 0.012 + rng.nextDouble() * 0.038,
      blurSigma: isSoft ? 7 + rng.nextDouble() * 8 : 2 + rng.nextDouble() * 3,
      isSoft: isSoft,
      canPulse: rng.nextDouble() > 0.58,
      rotationSeed: rng.nextDouble() * math.pi * 2,
      rotationSpeed: 0.08 + rng.nextDouble() * 0.22,
      rotationDir: rng.nextBool() ? 1.0 : -1.0,
      wobbleAmp: 0.008 + rng.nextDouble() * 0.02,
      wobbleSpeed: 0.45 + rng.nextDouble() * 0.55,
      windStrength: 0.004 + rng.nextDouble() * 0.012,
      windOffset: rng.nextDouble() * math.pi * 2,
      shapeBias: (rng.nextDouble() * 2) - 1,
      color: palette[rng.nextInt(palette.length)],
      centerColor: centerPalette[rng.nextInt(centerPalette.length)],
      edgeColor: edgePalette[rng.nextInt(edgePalette.length)],
    );
  }
}
