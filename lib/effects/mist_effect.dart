import 'package:flutter/material.dart';

import 'base_particle_effect.dart';

class MistEffect extends StatelessWidget {
  const MistEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseParticleEffect(
      seed: 9,
      shape: ParticleShape.blob,
      palette: [Color(0xFFEBC8D2), Color(0xFFDEB4BF)],
      blurStrength: 14,
    );
  }
}
