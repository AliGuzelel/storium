class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? unlocked,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}

class AchievementState {
  final Map<String, bool> completedStories;
  final Map<String, bool> achievements;

  const AchievementState({
    required this.completedStories,
    required this.achievements,
  });

  factory AchievementState.empty() {
    return const AchievementState(
      completedStories: {
        'depression': false,
        'loneliness': false,
        'grief': false,
      },
      achievements: {
        'shadow_walker': false,
        'still_here': false,
        'what_remains': false,
        'first_step': false,
        'story_seeker': false,
        'gentle_heart': false,
        'resilient_soul': false,
      },
    );
  }

  AchievementState copyWith({
    Map<String, bool>? completedStories,
    Map<String, bool>? achievements,
  }) {
    return AchievementState(
      completedStories: completedStories ?? this.completedStories,
      achievements: achievements ?? this.achievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {'completedStories': completedStories, 'achievements': achievements};
  }

  factory AchievementState.fromJson(Map<String, dynamic> json) {
    return AchievementState(
      completedStories: Map<String, bool>.from(
        json['completedStories'] ?? const {},
      ),
      achievements: Map<String, bool>.from(json['achievements'] ?? const {}),
    );
  }
}
