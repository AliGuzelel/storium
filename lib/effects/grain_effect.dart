import 'package:flutter/material.dart';

import 'base_particle_effect.dart';

class GrainEffect extends StatelessWidget {
  const GrainEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseParticleEffect(
      seed: 101,
      shape: ParticleShape.circle,
      palette: [Color(0xFFFFFFFF), Color(0xFFD4D4D4)],
      drawGrainOverlay: true,
      blurStrength: 7,
    );
  }
}
