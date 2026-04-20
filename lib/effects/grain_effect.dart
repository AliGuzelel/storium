import 'package:flutter/material.dart';

import 'base_particle_effect.dart';

class GrainEffect extends StatelessWidget {
  const GrainEffect({super.key, this.subtle = false});

  final bool subtle;

  @override
  Widget build(BuildContext context) {
    return BaseParticleEffect(
      seed: 101,
      shape: ParticleShape.circle,
      palette: const [Color(0xFFFFFFFF), Color(0xFFD4D4D4)],
      drawGrainOverlay: true,
      blurStrength: subtle ? 4.5 : 7,
      subtle: subtle,
    );
  }
}
