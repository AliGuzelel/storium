import 'dart:math' as math;

import 'package:flutter/material.dart';

class GreenTreeSceneEffect extends StatefulWidget {
  const GreenTreeSceneEffect({super.key});

  @override
  State<GreenTreeSceneEffect> createState() => _GreenTreeSceneEffectState();
}

class _GreenTreeSceneEffectState extends State<GreenTreeSceneEffect>
    with SingleTickerProviderStateMixin {
  static const int _leafCount = 56;

  late final AnimationController _controller;
  late final List<_LeafParticle> _leaves;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(71);
    _leaves = List<_LeafParticle>.generate(
      _leafCount,
      (_) => _LeafParticle.random(rng),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x1AA8D5BA),
                      Color(0x145A8F7B),
                      Color(0x0F4A7867),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: _GreenLeavesPainter(
                  t: _controller.value,
                  leaves: _leaves,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreenLeavesPainter extends CustomPainter {
  const _GreenLeavesPainter({required this.t, required this.leaves});

  final double t;
  final List<_LeafParticle> leaves;

  @override
  void paint(Canvas canvas, Size size) {
    _paintLeaves(canvas, size);
  }

  void _paintLeaves(Canvas canvas, Size size) {
    final leafPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < leaves.length; i++) {
      final p = leaves[i];
      final phase = (t * 2 * math.pi * p.speed) + p.phase;
      final baseX = p.spawnFromLeft
          ? ((t * p.windSpeed * size.width) + (p.x * size.width)) %
                (size.width * 1.25) -
            (size.width * 0.12)
          : ((p.x * size.width) + t * p.windSpeed * size.width) %
                (size.width * 1.25) -
            (size.width * 0.12);
      final baseY = p.spawnFromLeft
          ? ((p.y * size.height) + t * p.fallSpeed * size.height) %
                (size.height * 1.25) -
            (size.height * 0.12)
          : ((t * p.fallSpeed * size.height) + (p.y * size.height)) %
                (size.height * 1.25) -
            (size.height * 0.12);

      final x = baseX + math.sin(phase + p.windOffset) * 1.5;
      final y = baseY;
      final rot = p.rotationSeed + (phase * p.rotationSpeed);
      final path = createLeafPath(p.radius);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      leafPaint
        ..color = p.color.withValues(alpha: p.alpha)
        ..maskFilter = p.blur
            ? const MaskFilter.blur(BlurStyle.normal, 2.3)
            : null;
      canvas.drawPath(path, leafPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GreenLeavesPainter oldDelegate) =>
      oldDelegate.t != t;
}

Path createLeafPath(double size) {
  final path = Path();
  path.moveTo(0, -size * 0.5);
  path.quadraticBezierTo(size * 0.4, 0, 0, size * 0.5);
  path.quadraticBezierTo(-size * 0.4, 0, 0, -size * 0.5);
  path.close();
  return path;
}

class _LeafParticle {
  const _LeafParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.alpha,
    required this.speed,
    required this.fallSpeed,
    required this.windSpeed,
    required this.blur,
    required this.phase,
    required this.windOffset,
    required this.rotationSeed,
    required this.rotationSpeed,
    required this.spawnFromLeft,
    required this.color,
  });

  final double x;
  final double y;
  final double radius;
  final double alpha;
  final double speed;
  final double fallSpeed;
  final double windSpeed;
  final bool blur;
  final double phase;
  final double windOffset;
  final double rotationSeed;
  final double rotationSpeed;
  final bool spawnFromLeft;
  final Color color;

  factory _LeafParticle.random(math.Random random) {
    const palette = <Color>[
      Color(0xFF2F5D50),
      Color(0xFF3E6F5E),
      Color(0xFF526F47),
    ];
    final radius = 8.0 + random.nextDouble() * 14.0;
    final largeLeaf = radius > 15.5;
    return _LeafParticle(
      x: random.nextDouble() * 1.05,
      y: random.nextDouble() * 1.05,
      radius: radius,
      alpha: 0.24 + random.nextDouble() * 0.34,
      speed: 0.9 + random.nextDouble() * 0.7,
      fallSpeed: largeLeaf
          ? 0.22 + random.nextDouble() * 0.13
          : 0.12 + random.nextDouble() * 0.11,
      windSpeed: largeLeaf
          ? 0.28 + random.nextDouble() * 0.2
          : 0.18 + random.nextDouble() * 0.15,
      blur: random.nextDouble() < 0.38,
      phase: random.nextDouble() * math.pi * 2,
      windOffset: random.nextDouble() * math.pi * 2,
      rotationSeed: random.nextDouble() * math.pi * 2,
      rotationSpeed: 0.32 + random.nextDouble() * 0.55,
      spawnFromLeft: random.nextBool(),
      color: palette[random.nextInt(palette.length)],
    );
  }
}

