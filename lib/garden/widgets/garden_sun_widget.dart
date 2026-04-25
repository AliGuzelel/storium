import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Warm sun: clearly visible on light and dark skies, still soft-edged (no hard disc).
class GardenSunWidget extends StatefulWidget {
  const GardenSunWidget({super.key});

  @override
  State<GardenSunWidget> createState() => _GardenSunWidgetState();
}

class _GardenSunWidgetState extends State<GardenSunWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          // Full-bleed radial wash from upper-right — no cropped box (avoids vertical seam).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(1.05, -0.92),
                  radius: 1.08,
                  colors: [
                    const Color(0xFFFFF8E1).withValues(alpha: 0.10),
                    const Color(0xFFFFE082).withValues(alpha: 0.038),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.40, 1.0],
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
                // Broad warm halo — reads on dark themes.
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
                            Color(0xA8FFECB3),
                            Color(0x72FFD54F),
                            Color(0x38FFB300),
                            Color(0x0CFF9800),
                            Color(0x00FFFFFF),
                          ],
                          stops: [0.0, 0.28, 0.52, 0.78, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                // Bright core — strong focal point.
                Positioned(
                  top: 36,
                  right: 22,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                    child: Container(
                      width: 118,
                      height: 118,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment(-0.1, -0.12),
                          radius: 0.86,
                          colors: [
                            Color(0xDDFFFDE7),
                            Color(0xC8FFF9C4),
                            Color(0x6EFFEB3B),
                            Color(0x22FFC107),
                            Color(0x00FFFFFF),
                          ],
                          stops: [0.0, 0.22, 0.48, 0.72, 1.0],
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
