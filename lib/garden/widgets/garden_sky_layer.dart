import 'package:flutter/material.dart';

import 'garden_bird_widget.dart';
import 'garden_cloud_widget.dart';
import 'garden_sky_theme.dart';
import 'garden_sun_widget.dart';
import 'garden_theme_particles.dart';


class GardenSkyLayer extends StatelessWidget {
  const GardenSkyLayer({
    super.key,
    required this.themeColor,
    required this.brightness,
  });

  final String themeColor;
  final Brightness brightness;

  static const double _cloudBandHeightFactor = 0.38;

  @override
  Widget build(BuildContext context) {
    final gradient = gardenSkyGradient('blue', brightness);

    return KeyedSubtree(
      key: const ValueKey<String>('garden_sky_blue'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final cloudBandH = h * _cloudBandHeightFactor;

          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(gradient: gradient),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ClipRect(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: cloudBandH,
                    child: const GardenCloudsBand(),
                  ),
                ),
              ),
              Positioned.fill(
                child: GardenThemeParticlesLayer(themeColor: 'blue'),
              ),
              const GardenSunWidget(),
              Align(
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
      ),
    );
  }
}
