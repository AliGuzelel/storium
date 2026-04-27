import 'package:flutter/material.dart';

enum AchievementSection { stories, emotions, garden, activity }

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String hint;
  final IconData icon;
  final bool unlocked;
  final AchievementSection section;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.hint,
    required this.icon,
    required this.unlocked,
    required this.section,
  });

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? hint,
    IconData? icon,
    bool? unlocked,
    AchievementSection? section,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hint: hint ?? this.hint,
      icon: icon ?? this.icon,
      unlocked: unlocked ?? this.unlocked,
      section: section ?? this.section,
    );
  }
}

class UserStats {
  final int storiesCompleted;
  final int plantsGrown;
  final int daysActive;
  final int continuedStories;
  final String? lastVisitDayKey;

  const UserStats({
    this.storiesCompleted = 0,
    this.plantsGrown = 0,
    this.daysActive = 0,
    this.continuedStories = 0,
    this.lastVisitDayKey,
  });

  UserStats copyWith({
    int? storiesCompleted,
    int? plantsGrown,
    int? daysActive,
    int? continuedStories,
    String? lastVisitDayKey,
  }) {
    return UserStats(
      storiesCompleted: storiesCompleted ?? this.storiesCompleted,
      plantsGrown: plantsGrown ?? this.plantsGrown,
      daysActive: daysActive ?? this.daysActive,
      continuedStories: continuedStories ?? this.continuedStories,
      lastVisitDayKey: lastVisitDayKey ?? this.lastVisitDayKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'storiesCompleted': storiesCompleted,
        'plantsGrown': plantsGrown,
        'daysActive': daysActive,
        'continuedStories': continuedStories,
        'lastVisitDayKey': lastVisitDayKey,
      };

  factory UserStats.fromJson(Map<String, dynamic> json) {
    int parseInt(Object? v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return UserStats(
      storiesCompleted: parseInt(json['storiesCompleted']).clamp(0, 999999),
      plantsGrown: parseInt(json['plantsGrown']).clamp(0, 999999),
      daysActive: parseInt(json['daysActive']).clamp(0, 999999),
      continuedStories: parseInt(json['continuedStories']).clamp(0, 999999),
      lastVisitDayKey: json['lastVisitDayKey']?.toString(),
    );
  }
}

class AchievementState {
  final UserStats stats;
  final List<String> completedStoriesList;
  final Map<String, bool> achievements;

  const AchievementState({
    required this.stats,
    required this.completedStoriesList,
    required this.achievements,
  });

  factory AchievementState.empty() {
    return const AchievementState(
      stats: UserStats(),
      completedStoriesList: <String>[],
      achievements: {
        'first_story': false,
        'two_stories': false,
        'three_stories': false,
        'four_stories': false,
        'five_stories': false,
        'all_stories': false,
        'calm_80': false,
        'high_anxiety': false,
        'balance': false,
        'first_plant': false,
        'three_plants': false,
        'six_plants': false,
        'returning': false,
        'still_here': false,
        'stayed': false,
        'continued': false,
      },
    );
  }

  AchievementState copyWith({
    UserStats? stats,
    List<String>? completedStoriesList,
    Map<String, bool>? achievements,
  }) {
    return AchievementState(
      stats: stats ?? this.stats,
      completedStoriesList: completedStoriesList ?? this.completedStoriesList,
      achievements: achievements ?? this.achievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'completedStoriesList': completedStoriesList,
      'achievements': achievements,
    };
  }

  factory AchievementState.fromJson(Map<String, dynamic> json) {
    final statsMap = json['stats'] is Map
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : const <String, dynamic>{};
    return AchievementState(
      stats: UserStats.fromJson(statsMap),
      completedStoriesList: (json['completedStoriesList'] as List<dynamic>? ?? const [])
          .map((e) => e.toString().trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList()
        ..sort(),
      achievements: {
        ...AchievementState.empty().achievements,
        ...Map<String, bool>.from(json['achievements'] ?? const {}),
      },
    );
  }
}
