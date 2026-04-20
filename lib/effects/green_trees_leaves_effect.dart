import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/monotonic_seconds_ticker.dart';

class GreenTreeSceneEffect extends StatefulWidget {
  const GreenTreeSceneEffect({super.key, this.subtle = false});

  final bool subtle;

  @override
  State<GreenTreeSceneEffect> createState() => _GreenTreeSceneEffectState();
}

class _GreenTreeSceneEffectState extends State<GreenTreeSceneEffect> {
  static const int _leafCountFull = 56;
  static const int _leafCountSubtle = 18;

  /// Baseline loop length (matches prior AnimationController duration).
  static const double _loopSec = 26;

  late List<_LeafParticle> _leaves;

  void _rebuildLeaves() {
    final rng = math.Random(71);
    final n = widget.subtle ? _leafCountSubtle : _leafCountFull;
    _leaves = List<_LeafParticle>.generate(
      n,
      (_) => _LeafParticle.random(rng, subtle: widget.subtle),
    );
  }

  @override
  void initState() {
    super.initState();
    _rebuildLeaves();
  }

  @override
  void didUpdateWidget(covariant GreenTreeSceneEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subtle != widget.subtle) {
      _rebuildLeaves();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: widget.subtle
                        ? const [
                            Color(0x0FA8D5BA),
                            Color(0x0A5A8F7B),
                            Color(0x084A7867),
                          ]
                        : const [
                            Color(0x1AA8D5BA),
                            Color(0x145A8F7B),
                            Color(0x0F4A7867),
                          ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            MonotonicSecondsTicker(
              builder: (_, seconds) => CustomPaint(
                size: Size.infinite,
                painter: _GreenLeavesPainter(
                  t: seconds / _loopSec,
                  leaves: _leaves,
                  subtle: widget.subtle,
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
  const _GreenLeavesPainter({
    required this.t,
    required this.leaves,
    required this.subtle,
  });

  /// Monotonic “cycle” index (seconds / loop); modulo in paint keeps leaves smooth.
  final double t;
  final List<_LeafParticle> leaves;
  final bool subtle;

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

      final sway = subtle ? 1.0 : 1.5;
      final x = baseX + math.sin(phase + p.windOffset) * sway;
      final y = baseY;
      final rot = p.rotationSeed + (phase * p.rotationSpeed);
      final path = createLeafPath(p.radius);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      leafPaint
        ..color = p.color.withValues(alpha: p.alpha * (subtle ? 0.58 : 1.0))
        ..maskFilter = p.blur
            ? MaskFilter.blur(BlurStyle.normal, subtle ? 1.6 : 2.3)
            : null;
      canvas.drawPath(path, leafPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GreenLeavesPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.leaves != leaves ||
      oldDelegate.subtle != subtle;
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

  factory _LeafParticle.random(math.Random random, {bool subtle = false}) {
    const palette = <Color>[
      Color(0xFF2F5D50),
      Color(0xFF3E6F5E),
      Color(0xFF526F47),
    ];
    final radius = (8.0 + random.nextDouble() * 14.0) * (subtle ? 0.78 : 1.0);
    final largeLeaf = radius > 15.5;
    final sp = subtle ? 0.9 : 1.0;
    return _LeafParticle(
      x: random.nextDouble() * 1.05,
      y: random.nextDouble() * 1.05,
      radius: radius,
      alpha: (0.24 + random.nextDouble() * 0.34) * (subtle ? 0.82 : 1.0),
      speed: (0.9 + random.nextDouble() * 0.7) * sp,
      fallSpeed: (largeLeaf
              ? 0.22 + random.nextDouble() * 0.13
              : 0.12 + random.nextDouble() * 0.11) *
          sp,
      windSpeed: (largeLeaf
              ? 0.28 + random.nextDouble() * 0.2
              : 0.18 + random.nextDouble() * 0.15) *
          sp,
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

