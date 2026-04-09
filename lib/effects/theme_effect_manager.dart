import 'package:flutter/material.dart';

import 'blue_cloud_effect.dart';
import 'cherry_blossom_effect.dart';
import 'grain_effect.dart';
import 'green_trees_leaves_effect.dart';
import 'mist_effect.dart';
import 'purple_glow_effect.dart';

Widget buildThemeEffect(String themeColor) =>
    ThemeEffectManager.buildThemeEffect(themeColor);

class ThemeEffectManager {
  static Widget buildThemeEffect(String themeColor) {
    switch (themeColor) {
      case 'pink':
        return const CherryBlossomEffect();
      case 'blue':
        return const BlueCloudEffect();
      case 'green':
        return const GreenTreeSceneEffect();
      case 'red':
        return const MistEffect();
      case 'grayscale':
        return const GrainEffect();
      case 'purple':
      default:
        return const PurpleGlowEffect();
    }
  }
}
