import 'package:flutter/material.dart';

import 'base_particle_effect.dart';

class LeavesEffect extends StatelessWidget {
  const LeavesEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseParticleEffect(
      seed: 77,
      shape: ParticleShape.leaf,
      palette: [Color(0xFFCCF0D5), Color(0xFFAED8B9)],
      enableRotation: true,
      enableSway: true,
      blurStrength: 7,
    );
  }
}
