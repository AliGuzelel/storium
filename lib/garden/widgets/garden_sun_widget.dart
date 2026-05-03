import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';


class GardenSunWidget extends StatefulWidget {
  const GardenSunWidget({super.key});

  @override
  State<GardenSunWidget> createState() => _GardenSunWidgetState();
}

class _GardenSunWidgetState extends State<GardenSunWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulse;
  late AnimationController _rayTurn;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _rayTurn = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _rayTurn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(1.05, -0.92),
                  radius: 1.12,
                  colors: [
                    const Color(0xFFFFFDE7).withValues(alpha: 0.14),
                    const Color(0xFFFFE082).withValues(alpha: 0.055),
                    const Color(0xFFFFB74D).withValues(alpha: 0.018),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.32, 0.55, 1.0],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_pulse.value);
              final pulse = 0.96 + t * 0.04;
              return Transform.scale(
                scale: pulse,
                alignment: const Alignment(0.85, -0.65),
                child: Opacity(
                  opacity: 0.86 + t * 0.07,
                  child: child,
                ),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Rays share the same origin as the bright sun core (122×122 box).
                Positioned(
                  top: 36,
                  right: 22,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: 122,
                      height: 122,
                      child: OverflowBox(
                        maxWidth: 420,
                        maxHeight: 420,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 420,
                          height: 420,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_rayTurn, _pulse]),
                            builder: (context, _) {
                              final t =
                                  Curves.easeInOut.transform(_pulse.value);
                              return CustomPaint(
                                painter: _SunRaysPainter(
                                  center: const Offset(210, 210),
                                  rotation: _rayTurn.value * 2 * math.pi,
                                  shimmer: 0.55 + t * 0.45,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: -4,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment(-0.08, -0.08),
                          radius: 0.92,
                          colors: [
                            Color(0xB8FFECB3),
                            Color(0x82FFD54F),
                            Color(0x48FFB300),
                            Color(0x14FF9800),
                            Color(0x00FFFFFF),
                          ],
                          stops: [0.0, 0.28, 0.52, 0.78, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 36,
                  right: 22,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: 122,
                      height: 122,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment(-0.1, -0.12),
                          radius: 0.84,
                          colors: [
                            Color(0xE8FFFDE7),
                            Color(0xD8FFF9C4),
                            Color(0x7EFFEE58),
                            Color(0x28FFCA28),
                            Color(0x00FFFFFF),
                          ],
                          stops: [0.0, 0.20, 0.46, 0.70, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft rotating sunshine; [center] is the sun disc center in this painter's coordinates.
class _SunRaysPainter extends CustomPainter {
  _SunRaysPainter({
    required this.center,
    required this.rotation,
    required this.shimmer,
  });

  final Offset center;
  final double rotation;
  final double shimmer;

  @override
  void paint(Canvas canvas, Size size) {
    final len = size.shortestSide * 0.58;
    const rays = 18;
    final baseA = 0.045 + 0.035 * shimmer;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final glow = Paint()
      ..color = const Color(0xFFFFF8E1).withValues(alpha: baseA * 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    for (var i = 0; i < rays; i++) {
      final a = (i / rays) * math.pi * 2;
      final wobble = 0.88 + 0.12 * math.sin(a * 3 + rotation * 1.7);
      final x1 = math.cos(a - 0.04) * len * wobble;
      final y1 = math.sin(a - 0.04) * len * wobble;
      final x2 = math.cos(a + 0.04) * len * wobble;
      final y2 = math.sin(a + 0.04) * len * wobble;
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(x1, y1)
        ..lineTo(x2, y2)
        ..close();
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.center,
          end: Alignment(
            math.cos(a) * 0.9,
            math.sin(a) * 0.9,
          ),
          colors: [
            const Color(0xFFFFFDE7).withValues(alpha: baseA * 1.05),
            const Color(0xFFFFE082).withValues(alpha: baseA * 0.35),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: len));
      canvas.drawPath(path, paint);
    }

    for (var i = 0; i < rays; i++) {
      final a = (i / rays) * math.pi * 2 + 0.09;
      final x = math.cos(a) * len * 0.92;
      final y = math.sin(a) * len * 0.92;
      canvas.drawLine(Offset.zero, Offset(x, y), glow);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SunRaysPainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.rotation != rotation ||
      oldDelegate.shimmer != shimmer;
}
