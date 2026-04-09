import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/story_progress.dart';
import '../models/user_session.dart';
import '../models/achievement_model.dart';
import 'achievement_service.dart';

class StoryProgressService {
  final AchievementService _achievementService = AchievementService();

  static const String _prefsKeyPrefix = 'story_progress_data_';
  static const String _prefsAnnouncedAchievementsPrefix =
      'announced_achievements_';
  static const String _apiKey = 'AIzaSyAlISRVS8IBLbRJy-0whlGJ0dWLvX3UuBg';
  static const String _projectId = 'storium-6083e';

  String get _docBase =>
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/users';

  Future<StoryProgressData> load() async {
    final local = await _loadLocal();
    final user = UserSession.currentUser;

    if (user == null || user.uid.isEmpty || user.idToken.isEmpty) {
      return local;
    }

    final remote = await _fetchFromFirebase();
    if (remote != null) {
      await _saveLocal(remote);
      return remote;
    }

    return local;
  }

  Future<void> save(StoryProgressData data) async {
    await _saveLocal(data);
    await _syncToFirebase(data);
  }

  Future<void> recordProgress({
    required String storyTitle,
    required String topic,
    required int currentScene,
    required int calm,
    required int anxiety,
    required int currentChoicesMade,
  }) async {
    final current = await load();
    final normalizedTopic = _normalizeTopic(topic, storyTitle);

    final next = current.copyWith(
      currentStoryTitle: storyTitle,
      currentTopic: normalizedTopic,
      currentScene: currentScene,
      currentCalm: calm,
      currentAnxiety: anxiety,
      currentChoicesMade: currentChoicesMade,
      lastPlayedAt: DateTime.now(),
      lastStoryPlayed: normalizedTopic,
    );

    await save(next);
  }

  Future<List<AchievementModel>> markStoryCompleted({
    required String storyTitle,
    required String topic,
    required int choicesMadeInStory,
    required int calm,
    required int anxiety,
  }) async {
    final current = await load();
    final normalizedTopic = _normalizeTopic(topic, storyTitle);

    final finished = [...current.finishedStories];
    if (!finished.contains(normalizedTopic)) {
      finished.add(normalizedTopic);
    }

    final next = current.copyWith(
      clearCurrent: true,
      finishedStories: finished,
      totalChoicesMade: current.totalChoicesMade + choicesMadeInStory,
      lastPlayedAt: DateTime.now(),
      lastStoryPlayed: normalizedTopic,
      lastStoryCalm: calm,
      lastStoryAnxiety: anxiety,
    );

    await save(next);

    final beforeState = await _achievementService.loadState();
    final afterState = await _achievementService.syncWithStoryProgress(next);
    final rawUnlocked = _getNewlyUnlockedAchievements(beforeState, afterState);
    return _filterAndRememberAnnounced(rawUnlocked);
  }

  /// Prevents replaying all historical achievement popups after sign-in
  /// by seeding announced IDs with already unlocked achievements.
  Future<void> seedAnnouncedWithCurrentlyUnlocked() async {
    final progress = await load();
    final syncedState = await _achievementService.syncWithStoryProgress(progress);
    final announced = await _loadAnnouncedAchievementIds();
    final unlockedIds = syncedState.achievements.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key);
    announced.addAll(unlockedIds);
    await _saveAnnouncedAchievementIds(announced);
  }

  Future<List<AchievementModel>> _filterAndRememberAnnounced(
    List<AchievementModel> unlocked,
  ) async {
    if (unlocked.isEmpty) return const [];
    final announced = await _loadAnnouncedAchievementIds();
    final fresh = unlocked.where((a) => !announced.contains(a.id)).toList();
    if (fresh.isEmpty) return const [];
    announced.addAll(fresh.map((a) => a.id));
    await _saveAnnouncedAchievementIds(announced);
    return fresh;
  }

  List<AchievementModel> _getNewlyUnlockedAchievements(
    AchievementState before,
    AchievementState after,
  ) {
    final beforeAchievements = before.achievements;
    final afterAchievements = after.achievements;

    final allModels = _achievementService.buildAchievementModels(after);

    return allModels.where((achievement) {
      final wasUnlocked = beforeAchievements[achievement.id] ?? false;
      final isUnlocked = afterAchievements[achievement.id] ?? false;
      return !wasUnlocked && isUnlocked;
    }).toList();
  }

  String _normalizeTopic(String topic, String storyTitle) {
    final raw = topic.trim().toLowerCase();

    if (raw.contains('depression')) return 'depression';
    if (raw.contains('loneliness')) return 'loneliness';
    if (raw.contains('grief')) return 'grief';

    final title = storyTitle.trim().toLowerCase();

    if (title.contains('what still remains')) return 'depression';
    if (title.contains('alone, again')) return 'loneliness';
    if (title.contains('the day after')) return 'grief';

    return raw;
  }

  Future<void> _syncToFirebase(StoryProgressData data) async {
    final user = UserSession.currentUser;
    if (user == null || user.uid.isEmpty || user.idToken.isEmpty) return;

    final uri = Uri.parse(
      '$_docBase/${user.uid}?key=$_apiKey&updateMask.fieldPaths=storyProgressJson',
    );
    final body = {
      'fields': {
        'storyProgressJson': {'stringValue': jsonEncode(data.toJson())},
      },
    };

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.idToken}',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 404) {
      await http.put(
        Uri.parse('$_docBase/${user.uid}?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.idToken}',
        },
        body: jsonEncode(body),
      );
    }
  }

  Future<StoryProgressData?> _fetchFromFirebase() async {
    final user = UserSession.currentUser;
    if (user == null || user.uid.isEmpty || user.idToken.isEmpty) return null;

    final uri = Uri.parse('$_docBase/${user.uid}?key=$_apiKey');
    final resp = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.idToken}',
      },
    );

    if (resp.statusCode != 200) return null;

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final fields = decoded['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final rawProgress =
        (fields['storyProgressJson'] as Map<String, dynamic>?)?['stringValue']
            as String?;

    if (rawProgress == null || rawProgress.isEmpty) return null;

    final progressJson = jsonDecode(rawProgress) as Map<String, dynamic>;
    return StoryProgressData.fromJson(progressJson);
  }

  String _prefsKeyForUser() {
    final user = UserSession.currentUser;
    if (user == null || user.uid.isEmpty) {
      return '${_prefsKeyPrefix}guest';
    }
    return '$_prefsKeyPrefix${user.uid}';
  }

  Future<StoryProgressData> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyForUser());

    if (raw == null || raw.isEmpty) {
      return const StoryProgressData();
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return StoryProgressData.fromJson(decoded);
  }

  Future<void> _saveLocal(StoryProgressData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyForUser(), jsonEncode(data.toJson()));
  }

  String _announcedKeyForUser() {
    final user = UserSession.currentUser;
    if (user == null || user.uid.isEmpty) {
      return '${_prefsAnnouncedAchievementsPrefix}guest';
    }
    return '$_prefsAnnouncedAchievementsPrefix${user.uid}';
  }

  Future<Set<String>> _loadAnnouncedAchievementIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_announcedKeyForUser()) ?? const <String>[])
        .toSet();
  }

  Future<void> _saveAnnouncedAchievementIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_announcedKeyForUser(), ids.toList()..sort());
  }
}
