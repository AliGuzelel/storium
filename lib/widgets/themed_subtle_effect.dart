import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../effects/theme_effect_manager.dart';
import '../providers/settings_manager.dart';



class ThemedSubtleEffect extends StatelessWidget {
  const ThemedSubtleEffect({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<SettingsManager>().themeColor;
    if (themeColor == 'yellow') {
      return child;
    }

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: KeyedSubtree(
            key: ValueKey<String>('theme_fx_$themeColor'),
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ThemeEffectManager.buildThemeEffect(
                  themeColor,
                  subtle: true,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
