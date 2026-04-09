import 'package:flutter/material.dart';

import '../models/achievement_model.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback? onTap;

  const AchievementCard({super.key, required this.achievement, this.onTap});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    final baseColor = unlocked
        ? Colors.white.withOpacity(0.18)
        : Colors.white.withOpacity(0.08);
    final borderColor = unlocked
        ? Colors.white.withOpacity(0.28)
        : Colors.white.withOpacity(0.14);
    final titleColor = unlocked
        ? Colors.white.withOpacity(0.95)
        : Colors.white.withOpacity(0.66);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.12),
                    blurRadius: 12,
                    spreadRadius: 0.5,
                  ),
                ]
              : const [],
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
                unlocked ? Icons.emoji_events_rounded : Icons.lock_rounded,
                color: unlocked
                    ? Colors.white.withOpacity(0.95)
                    : Colors.white.withOpacity(0.65),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
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
    );
  }
}
