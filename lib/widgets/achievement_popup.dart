import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement_model.dart';

Future<void> showAchievementPopup(
  BuildContext context,
  String title,
  String description, {
  IconData icon = Icons.emoji_events_rounded,
  String? label,
  Duration autoCloseAfter = const Duration(seconds: 2),
}) async {
  HapticFeedback.lightImpact();
  var closed = false;
  Future<void>.delayed(autoCloseAfter, () {
    if (closed || !context.mounted) return;
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) {
      closed = true;
      nav.pop();
    }
  });
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Achievement unlocked',
    barrierColor: Colors.black.withValues(alpha: 0.36),
    builder: (ctx) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.95, end: 1),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: SizedBox(
              width: 280,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.26),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.24),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 30, color: Colors.white),
                        if (label != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          title,
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
                          description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.5,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  closed = true;
}

Future<void> showAchievementsSequence(
  BuildContext context,
  List<AchievementModel> achievements,
) async {
  if (achievements.isEmpty) return;
  for (final achievement in achievements) {
    if (!context.mounted) return;
    await showAchievementPopup(
      context,
      achievement.title,
      achievement.description,
      icon: achievement.icon,
      label: 'ACHIEVED!',
    );
  }
}
