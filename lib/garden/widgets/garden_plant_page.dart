import 'package:flutter/material.dart';

import 'plant_widget.dart';

/// One [PageView] page: plant anchored so its base meets the soil line.
class PlantPage extends StatelessWidget {
  const PlantPage({
    super.key,
    required this.imagePath,
    required this.currentPhase,
    required this.glowEpoch,
    required this.glowTint,
    required this.plantImageHeight,
    this.plantImageWidthFactor = 0.88,
    this.bottomOffset = 0,
  });

  final String imagePath;
  final int currentPhase;
  final int glowEpoch;
  final Color glowTint;
  final double plantImageHeight;
  final double plantImageWidthFactor;
  final double bottomOffset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final plantW = (w * plantImageWidthFactor).clamp(200.0, 400.0);
        final plantH = plantImageHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: PlantWidget(
                imagePath: imagePath,
                currentPhase: currentPhase,
                glowEpoch: glowEpoch,
                glowTint: glowTint,
                maxWidth: plantW,
                maxHeight: plantH,
                bottomOffset: bottomOffset,
              ),
            ),
          ],
        );
      },
    );
  }
}
