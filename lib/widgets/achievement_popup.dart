import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement_model.dart';
import '../theme/ui_tokens.dart';
import 'app_button.dart';

class AchievementPopup extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback onContinue;

  const AchievementPopup({
    super.key,
    required this.achievement,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        borderRadius: UiTokens.surfaceBorderRadius,
        color: Colors.white.withOpacity(0.14),
        border: Border.fromBorderSide(UiTokens.surfaceBorderSide),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Achievement Unlocked',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB59BFF).withOpacity(0.35),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(achievement.icon, style: const TextStyle(fontSize: 44)),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              height: 1.35,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 160,
            child: AppButton(label: 'Continue', onTap: onContinue),
          ),
        ],
      ),
    );
  }
}

Future<void> showAchievementPopup(
  BuildContext context,
  AchievementModel achievement,
) async {
  HapticFeedback.lightImpact();
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Achievement unlocked',
    barrierColor: Colors.black.withOpacity(0.28),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.96, end: 1),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                builder: (context, scale, child) {
                  return Opacity(
                    opacity: animation.value,
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: AchievementPopup(
                  achievement: achievement,
                  onContinue: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

Future<void> showAchievementsSequence(
  BuildContext context,
  List<AchievementModel> achievements,
) async {
  if (achievements.isEmpty) return;
  for (final achievement in achievements) {
    if (!context.mounted) return;
    await showAchievementPopup(context, achievement);
  }
}
