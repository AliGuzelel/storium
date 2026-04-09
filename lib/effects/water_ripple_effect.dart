import 'package:flutter/material.dart';

import 'base_particle_effect.dart';

class WaterRippleEffect extends StatelessWidget {
  const WaterRippleEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseParticleEffect(
      seed: 64,
      shape: ParticleShape.circle,
      palette: [Color(0xFFC3E6FF), Color(0xFFD9F0FF)],
      blurStrength: 7,
    );
  }
}
