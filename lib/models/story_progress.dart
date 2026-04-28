class StoryProgressData {
  final String? currentStoryTitle;
  final String? currentTopic;
  final int? currentScene;
  final int currentCalm;
  final int currentAnxiety;
  final int currentChoicesMade;
  final DateTime? lastPlayedAt;
  final List<String> finishedStories;
  
  final Map<String, int> inProgressStories;
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
    this.inProgressStories = const {},
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
    Map<String, int>? inProgressStories,
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
      inProgressStories: inProgressStories ?? this.inProgressStories,
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
      'inProgressStories': inProgressStories,
      'totalChoicesMade': totalChoicesMade,
      'lastStoryPlayed': lastStoryPlayed,
      'lastStoryCalm': lastStoryCalm,
      'lastStoryAnxiety': lastStoryAnxiety,
    };
  }

  factory StoryProgressData.fromJson(Map<String, dynamic> json) {
    final rawDate = json['lastPlayedAt'] as String?;
    final rawStories = json['finishedStories'] as List<dynamic>? ?? const [];
    final rawInProgress = json['inProgressStories'];
    final inProgress = <String, int>{};
    if (rawInProgress is Map) {
      rawInProgress.forEach((k, v) {
        final scene = _parseIntLoose(v);
        if (scene != null) inProgress[k.toString()] = scene;
      });
    }
    return StoryProgressData(
      currentStoryTitle: json['currentStoryTitle'] as String?,
      currentTopic: json['currentTopic'] as String?,
      currentScene: _parseIntLoose(json['currentScene']),
      currentCalm: _parseIntLoose(json['currentCalm']) ?? 0,
      currentAnxiety: _parseIntLoose(json['currentAnxiety']) ?? 0,
      currentChoicesMade: _parseIntLoose(json['currentChoicesMade']) ?? 0,
      lastPlayedAt: rawDate == null ? null : DateTime.tryParse(rawDate),
      finishedStories: rawStories.map((e) => e.toString()).toList(),
      inProgressStories: inProgress,
      totalChoicesMade: _parseIntLoose(json['totalChoicesMade']) ?? 0,
      lastStoryPlayed: json['lastStoryPlayed'] as String?,
      lastStoryCalm: _parseIntLoose(json['lastStoryCalm']) ?? 0,
      lastStoryAnxiety: _parseIntLoose(json['lastStoryAnxiety']) ?? 0,
    );
  }

  static int? _parseIntLoose(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
