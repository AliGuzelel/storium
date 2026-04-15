import 'package:flutter/material.dart';

import 'garden_bird_widget.dart';
import 'garden_cloud_widget.dart';
import 'garden_sky_theme.dart';
import 'garden_sun_widget.dart';

/// Full-screen calm sky. Layer order (bottom → top): gradient → clouds → sun → birds.
/// Clouds are clipped to the upper band only so they never sit over the plant strip.
class GardenSkyLayer extends StatelessWidget {
  const GardenSkyLayer({
    super.key,
    required this.themeColor,
    required this.brightness,
  });

  final String themeColor;
  final Brightness brightness;

  /// Drifting clouds only in the top portion of the screen (above the plant strip).
  static const double _cloudBandHeightFactor = 0.36;

  @override
  Widget build(BuildContext context) {
    final colors = gardenSkyGradientColors(themeColor, brightness);
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final cloudBandH = h * _cloudBandHeightFactor;
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors,
                  stops: const [0.0, 0.22, 0.4, 0.58, 0.78],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ClipRect(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: cloudBandH,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Large / medium — slow drift
                      CloudWidget(
                        travelDuration: const Duration(seconds: 38),
                        verticalFraction: 0.30,
                        horizontalPhase: 0.05,
                        opacity: 0.15,
                        scale: 1.05,
                        shape: 0,
                      ),
                      CloudWidget(
                        travelDuration: const Duration(seconds: 34),
                        verticalFraction: 0.52,
                        horizontalPhase: 0.38,
                        opacity: 0.13,
                        scale: 0.92,
                        shape: 1,
                      ),
                      CloudWidget(
                        travelDuration: const Duration(seconds: 42),
                        verticalFraction: 0.14,
                        horizontalPhase: 0.72,
                        opacity: 0.14,
                        scale: 0.88,
                        shape: 2,
                      ),
                      // Smaller wisps
                      CloudWidget(
                        travelDuration: const Duration(seconds: 36),
                        verticalFraction: 0.68,
                        horizontalPhase: 0.18,
                        opacity: 0.12,
                        scale: 0.62,
                        shape: 1,
                      ),
                      CloudWidget(
                        travelDuration: const Duration(seconds: 40),
                        verticalFraction: 0.08,
                        horizontalPhase: 0.55,
                        opacity: 0.11,
                        scale: 0.58,
                        shape: 2,
                      ),
                      CloudWidget(
                        travelDuration: const Duration(seconds: 44),
                        verticalFraction: 0.42,
                        horizontalPhase: 0.82,
                        opacity: 0.12,
                        scale: 0.72,
                        shape: 0,
                      ),
                      CloudWidget(
                        travelDuration: const Duration(seconds: 32),
                        verticalFraction: 0.22,
                        horizontalPhase: 0.30,
                        opacity: 0.13,
                        scale: 0.78,
                        shape: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: SunWidget()),
            const Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                heightFactor: 0.58,
                widthFactor: 1,
                child: BirdsWidget(),
              ),
            ),
          ],
        );
      },
    );
  }
}
