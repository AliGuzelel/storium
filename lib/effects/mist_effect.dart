import 'package:flutter/material.dart';

import 'base_particle_effect.dart';

class MistEffect extends StatelessWidget {
  const MistEffect({super.key, this.subtle = false});

  final bool subtle;

  @override
  Widget build(BuildContext context) {
    return BaseParticleEffect(
      seed: 9,
      shape: ParticleShape.blob,
      palette: const [Color(0xFFEBC8D2), Color(0xFFDEB4BF)],
      blurStrength: subtle ? 9 : 14,
      subtle: subtle,
    );
  }
}
