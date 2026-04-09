class StoryProgressData {
  final String? currentStoryTitle;
  final String? currentTopic;
  final int? currentScene;
  final int currentCalm;
  final int currentAnxiety;
  final int currentChoicesMade;
  final DateTime? lastPlayedAt;
  final List<String> finishedStories;
  final int totalChoicesMade;
  final String? lastStoryPlayed;
  final int lastStoryCalm;
  final int lastStoryAnxiety;

  const StoryProgressData({
    this.currentStoryTitle,
    this.currentTopic,
    this.currentScene,
    this.currentCalm = 0,
    this.currentAnxiety = 0,
    this.currentChoicesMade = 0,
    this.lastPlayedAt,
    this.finishedStories = const [],
    this.totalChoicesMade = 0,
    this.lastStoryPlayed,
    this.lastStoryCalm = 0,
    this.lastStoryAnxiety = 0,
  });

  StoryProgressData copyWith({
    String? currentStoryTitle,
    String? currentTopic,
    int? currentScene,
    int? currentCalm,
    int? currentAnxiety,
    int? currentChoicesMade,
    DateTime? lastPlayedAt,
    List<String>? finishedStories,
    int? totalChoicesMade,
    String? lastStoryPlayed,
    int? lastStoryCalm,
    int? lastStoryAnxiety,
    bool clearCurrent = false,
  }) {
    return StoryProgressData(
      currentStoryTitle: clearCurrent
          ? null
          : (currentStoryTitle ?? this.currentStoryTitle),
      currentTopic: clearCurrent ? null : (currentTopic ?? this.currentTopic),
      currentScene: clearCurrent ? null : (currentScene ?? this.currentScene),
      currentCalm: clearCurrent ? 0 : (currentCalm ?? this.currentCalm),
      currentAnxiety: clearCurrent ? 0 : (currentAnxiety ?? this.currentAnxiety),
      currentChoicesMade: clearCurrent
          ? 0
          : (currentChoicesMade ?? this.currentChoicesMade),
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      finishedStories: finishedStories ?? this.finishedStories,
      totalChoicesMade: totalChoicesMade ?? this.totalChoicesMade,
      lastStoryPlayed: lastStoryPlayed ?? this.lastStoryPlayed,
      lastStoryCalm: lastStoryCalm ?? this.lastStoryCalm,
      lastStoryAnxiety: lastStoryAnxiety ?? this.lastStoryAnxiety,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStoryTitle': currentStoryTitle,
      'currentTopic': currentTopic,
      'currentScene': currentScene,
      'currentCalm': currentCalm,
      'currentAnxiety': currentAnxiety,
      'currentChoicesMade': currentChoicesMade,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'finishedStories': finishedStories,
      'totalChoicesMade': totalChoicesMade,
      'lastStoryPlayed': lastStoryPlayed,
      'lastStoryCalm': lastStoryCalm,
      'lastStoryAnxiety': lastStoryAnxiety,
    };
  }

  factory StoryProgressData.fromJson(Map<String, dynamic> json) {
    final rawDate = json['lastPlayedAt'] as String?;
    final rawStories = json['finishedStories'] as List<dynamic>? ?? const [];
    return StoryProgressData(
      currentStoryTitle: json['currentStoryTitle'] as String?,
      currentTopic: json['currentTopic'] as String?,
      currentScene: json['currentScene'] as int?,
      currentCalm: (json['currentCalm'] as int?) ?? 0,
      currentAnxiety: (json['currentAnxiety'] as int?) ?? 0,
      currentChoicesMade: (json['currentChoicesMade'] as int?) ?? 0,
      lastPlayedAt: rawDate == null ? null : DateTime.tryParse(rawDate),
      finishedStories: rawStories.map((e) => e.toString()).toList(),
      totalChoicesMade: (json['totalChoicesMade'] as int?) ?? 0,
      lastStoryPlayed: json['lastStoryPlayed'] as String?,
      lastStoryCalm: (json['lastStoryCalm'] as int?) ?? 0,
      lastStoryAnxiety: (json['lastStoryAnxiety'] as int?) ?? 0,
    );
  }
}
