
abstract final class StoryResumeCatalog {
  static const Map<String, String> titles = {
    'too_loud_inside': 'Too Loud Inside',
    'alone_again': 'Alone, Again',
    'what_still_remains': 'What Still Remains',
    'the_day_after': 'The Space You Left',
    'almost_there': 'Almost There',
  };

  static const Map<String, String> emojis = {
    'too_loud_inside': '🧠',
    'alone_again': '🌫️',
    'what_still_remains': '🌙',
    'the_day_after': '🕊️',
    'almost_there': '⏳',
  };

  static String? storyIdFromStoryTitleAndTopic({
    required String storyTitle,
    required String topic,
  }) {
    final normalizedTitle = storyTitle.trim().toLowerCase();
    for (final e in titles.entries) {
      if (normalizedTitle == e.value.trim().toLowerCase()) return e.key;
    }
    return storyIdFromNormalizedTopic(topic);
  }

  
  static String? storyIdFromNormalizedTopic(String topic) {
    switch (topic.trim().toLowerCase()) {
      case 'grief':
        return 'the_day_after';
      case 'depression':
        return 'what_still_remains';
      case 'loneliness':
        return 'alone_again';
      case 'failure':
        return 'almost_there';
      case 'anxiety':
        return 'too_loud_inside';
    }
    return null;
  }

  static Set<String> storyIdsForFinishedTopics(List<String> finishedTopics) {
    final out = <String>{};
    for (final raw in finishedTopics) {
      final id = storyIdFromNormalizedTopic(raw);
      if (id != null) out.add(id);
    }
    return out;
  }

  static String displayTitleForId(String storyId) {
    return titles[storyId] ?? _prettifyId(storyId);
  }

  static String _prettifyId(String storyId) {
    if (storyId.isEmpty) return 'Story';
    return storyId
        .split('_')
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }
}
