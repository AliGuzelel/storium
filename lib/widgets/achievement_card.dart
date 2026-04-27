import 'package:flutter/material.dart';
import 'dart:ui';

import '../models/achievement_model.dart';
import '../theme/ui_tokens.dart';
import 'localized_text.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback? onTap;

  const AchievementCard({super.key, required this.achievement, this.onTap});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    final baseColor = unlocked
        ? Colors.white.withOpacity(0.2)
        : Colors.white.withOpacity(0.08);
    final titleColor = unlocked
        ? Colors.white.withOpacity(0.95)
        : Colors.white.withOpacity(0.62);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: unlocked ? 1 : 0.42,
        child: ColorFiltered(
          colorFilter: unlocked
              ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
              : const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
          child: Container(
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: UiTokens.surfaceBorderRadius,
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: const Color(0xFFB8E0FF).withOpacity(0.22),
                        blurRadius: 16,
                        spreadRadius: 0.8,
                      ),
                    ]
                  : const [],
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: unlocked ? 0 : 1.3,
                      sigmaY: unlocked ? 0 : 1.3,
                    ),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: unlocked
                            ? Colors.white.withOpacity(0.22)
                            : Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(
                        achievement.icon,
                        color: unlocked
                            ? Colors.white.withOpacity(0.95)
                            : Colors.white.withOpacity(0.62),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                LocalizedText(
                  achievement.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    color: titleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
