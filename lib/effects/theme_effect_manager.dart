import 'package:flutter/material.dart';

import 'ash_haze_effect.dart';
import 'blue_cloud_effect.dart';
import 'cherry_blossom_effect.dart';
import 'cherry_float_effect.dart';
import 'green_trees_leaves_effect.dart';
import 'purple_glow_effect.dart';

Widget buildThemeEffect(String themeColor, {bool subtle = false}) =>
    ThemeEffectManager.buildThemeEffect(themeColor, subtle: subtle);

class ThemeEffectManager {
  static Widget buildThemeEffect(String themeColor, {bool subtle = false}) {
    switch (themeColor) {
      case 'pink':
        return CherryBlossomEffect(subtle: subtle);
      case 'blue':
        return BlueCloudEffect(subtle: subtle);
      case 'green':
        return GreenTreeSceneEffect(subtle: subtle);
      case 'yellow':
        return const SizedBox.shrink();
      case 'red':
        return CherryFloatEffect(subtle: subtle);
      case 'grayscale':
        return AshHazeEffect(subtle: subtle);
      case 'purple':
      default:
        return PurpleGlowEffect(subtle: subtle);
    }
  }
}
