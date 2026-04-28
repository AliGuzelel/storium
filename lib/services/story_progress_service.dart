import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/in_progress_story.dart';
import '../models/story_progress.dart';
import '../models/user_session.dart';
import '../models/achievement_model.dart';
import '../utils/story_resume_catalog.dart';
import 'achievement_service.dart';
import 'firebase_project_config.dart';
import 'firestore_user_document_repository.dart';

class StoryProgressService {
  final AchievementService _achievementService = AchievementService();

  static const String _prefsKeyPrefix = 'story_progress_data_';
  static const String _prefsAnnouncedAchievementsPrefix =
      'announced_achievements_';
  String get _docBase =>
      '${FirebaseProjectConfig.firestoreDocumentsBase}/users';

  Future<StoryProgressData> load() async {
    await _migrateGuestProgressIfNeeded();
    final local = await _loadLocal();
    final user = UserSession.currentUser;

    if (user == null || user.uid.isEmpty || user.idToken.isEmpty) {
      return _hydrateInProgressIfNeeded(local);
    }

    final remote = await _fetchFromFirebase();
    if (remote != null) {
      var merged = _mergeLocalAndRemoteStoryProgress(local, remote);
      merged = _hydrateInProgressIfNeeded(merged);
      merged = _stripInProgressForFinishedStories(merged);
      await _saveLocal(merged);
      await _syncToFirebase(merged);
      return merged;
    }

    return _hydrateInProgressIfNeeded(_stripInProgressForFinishedStories(local));
  }

  
  Future<List<InProgressStory>> loadContinuableStories() async {
    final progress = await load();
    final merged = Map<String, int>.from(progress.inProgressStories);
    _foldCurrentSessionIntoMap(progress, merged);
    merged.removeWhere((_, scene) => scene < 1);

    List<InProgressStory> toSortedList(Map<String, int> source) {
      return source.entries
          .where((e) => e.value >= 1)
          .map(
            (e) => InProgressStory(storyId: e.key, sceneIndex: e.value),
          )
          .toList()
        ..sort(
          (a, b) => StoryResumeCatalog.displayTitleForId(
            a.storyId,
          ).compareTo(StoryResumeCatalog.displayTitleForId(b.storyId)),
        );
    }

    final finished =
        StoryResumeCatalog.storyIdsForFinishedTopics(progress.finishedStories);
    final strict = Map<String, int>.from(merged)
      ..removeWhere((storyId, _) => finished.contains(storyId));
    final strictList = toSortedList(strict);
    if (strictList.isNotEmpty) return strictList;

    
    
    return toSortedList(merged);
  }

  Future<List<InProgressStory>> fetchUnfinishedStories() {
    return loadContinuableStories();
  }

  
  Future<void> _migrateGuestProgressIfNeeded() async {
    final user = UserSession.currentUser;
    if (user == null || user.uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final userKey = '$_prefsKeyPrefix${user.uid}';
    final guestKey = '${_prefsKeyPrefix}guest';
    final existing = prefs.getString(userKey);
    if (existing != null && existing.isNotEmpty) return;
    final guestRaw = prefs.getString(guestKey);
    if (guestRaw == null || guestRaw.isEmpty) return;
    await prefs.setString(userKey, guestRaw);
  }

  StoryProgressData _mergeLocalAndRemoteStoryProgress(
    StoryProgressData local,
    StoryProgressData remote,
  ) {
    final mergedMap = _mergeInProgressSceneMaps(
      local.inProgressStories,
      remote.inProgressStories,
    );
    final mergedFinished = {
      ...local.finishedStories,
      ...remote.finishedStories,
    }.toList();

    final useLocalSession = _isLocalSessionNewer(local, remote);
    if (useLocalSession) {
      return remote.copyWith(
        inProgressStories: mergedMap,
        finishedStories: mergedFinished,
        currentStoryTitle: local.currentStoryTitle ?? remote.currentStoryTitle,
        currentTopic: local.currentTopic ?? remote.currentTopic,
        currentScene: local.currentScene ?? remote.currentScene,
        currentCalm: local.currentCalm,
        currentAnxiety: local.currentAnxiety,
        currentChoicesMade: local.currentChoicesMade,
        lastPlayedAt: local.lastPlayedAt ?? remote.lastPlayedAt,
        lastStoryPlayed: local.lastStoryPlayed ?? remote.lastStoryPlayed,
        lastStoryCalm: local.lastStoryCalm,
        lastStoryAnxiety: local.lastStoryAnxiety,
        totalChoicesMade: local.totalChoicesMade > remote.totalChoicesMade
            ? local.totalChoicesMade
            : remote.totalChoicesMade,
      );
    }

    return remote.copyWith(
      inProgressStories: mergedMap,
      finishedStories: mergedFinished,
    );
  }

  bool _isLocalSessionNewer(StoryProgressData local, StoryProgressData remote) {
    final lt = local.lastPlayedAt;
    final rt = remote.lastPlayedAt;
    if (lt == null) return false;
    if (rt == null) return true;
    return !lt.isBefore(rt);
  }

  Map<String, int> _mergeInProgressSceneMaps(
    Map<String, int> a,
    Map<String, int> b,
  ) {
    final out = Map<String, int>.from(b);
    a.forEach((k, v) {
      final existing = out[k] ?? 0;
      out[k] = v > existing ? v : existing;
    });
    return out;
  }

  StoryProgressData _hydrateInProgressIfNeeded(StoryProgressData data) {
    final map = Map<String, int>.from(data.inProgressStories);
    _foldCurrentSessionIntoMap(data, map);
    return data.copyWith(inProgressStories: map);
  }

  
  
  
  void _foldCurrentSessionIntoMap(
    StoryProgressData data,
    Map<String, int> merged,
  ) {
    final scene = data.currentScene;
    final topic = data.currentTopic;
    if (scene == null || scene < 1 || topic == null || topic.isEmpty) {
      return;
    }
    final sid = StoryResumeCatalog.storyIdFromStoryTitleAndTopic(
          storyTitle: data.currentStoryTitle ?? '',
          topic: topic,
        ) ??
        StoryResumeCatalog.storyIdFromNormalizedTopic(topic);
    if (sid == null) return;
    final prev = merged[sid] ?? 0;
    merged[sid] = scene > prev ? scene : prev;
  }

  StoryProgressData _stripInProgressForFinishedStories(StoryProgressData data) {
    final done = StoryResumeCatalog.storyIdsForFinishedTopics(data.finishedStories);
    if (done.isEmpty) return data;
    final map = Map<String, int>.from(data.inProgressStories);
    map.removeWhere((id, _) => done.contains(id));
    return data.copyWith(inProgressStories: map);
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
    String? resumeStoryId,
  }) async {
    final current = await load();
    final normalizedTopic = _normalizeTopic(topic, storyTitle);
    final storyId = _resolveResumeStoryId(
      resumeStoryId: resumeStoryId,
      storyTitle: storyTitle,
      normalizedTopic: normalizedTopic,
      rawTopic: topic,
    );
    final inProgress = Map<String, int>.from(current.inProgressStories);
    if (storyId != null && currentScene > 0) {
      inProgress[storyId] = currentScene;
    }
    final finished = <String>[
      ...current.finishedStories.where((t) => t != normalizedTopic),
    ];

    final next = current.copyWith(
      currentStoryTitle: storyTitle,
      currentTopic: normalizedTopic,
      currentScene: currentScene,
      currentCalm: calm,
      currentAnxiety: anxiety,
      currentChoicesMade: currentChoicesMade,
      lastPlayedAt: DateTime.now(),
      lastStoryPlayed: normalizedTopic,
      inProgressStories: inProgress,
      finishedStories: finished,
    );

    await save(next);
  }

  Future<List<AchievementModel>> markStoryCompleted({
    required String storyTitle,
    required String topic,
    required int choicesMadeInStory,
    required int calm,
    required int anxiety,
    String? resumeStoryId,
    bool resumedFromSavedProgress = false,
  }) async {
    final current = await load();
    final normalizedTopic = _normalizeTopic(topic, storyTitle);

    final finished = [...current.finishedStories];
    if (!finished.contains(normalizedTopic)) {
      finished.add(normalizedTopic);
    }

    final storyId = _resolveResumeStoryId(
          resumeStoryId: resumeStoryId,
          storyTitle: storyTitle,
          normalizedTopic: normalizedTopic,
          rawTopic: topic,
        ) ??
        StoryResumeCatalog.storyIdFromNormalizedTopic(normalizedTopic);
    final inProgress = Map<String, int>.from(current.inProgressStories);
    if (storyId != null) inProgress.remove(storyId);

    final next = current.copyWith(
      clearCurrent: true,
      finishedStories: finished,
      totalChoicesMade: current.totalChoicesMade + choicesMadeInStory,
      lastPlayedAt: DateTime.now(),
      lastStoryPlayed: normalizedTopic,
      lastStoryCalm: calm,
      lastStoryAnxiety: anxiety,
      inProgressStories: inProgress,
    );

    await save(next);

    final beforeState = await _achievementService.loadState();
    final total = StoryResumeCatalog.titles.length;
    final calmPercent = (calm + anxiety) == 0
        ? 0
        : ((calm / (calm + anxiety)) * 100).round();
    final anxietyPercent = (calm + anxiety) == 0
        ? 0
        : ((anxiety / (calm + anxiety)) * 100).round();
    final storyIdForAchievements = (storyId ?? normalizedTopic).toLowerCase();
    final snapshotStoryIds = next.finishedStories
        .map((topic) => StoryResumeCatalog.storyIdFromNormalizedTopic(topic))
        .whereType<String>()
        .toSet()
      ..add(storyIdForAchievements);
    await _achievementService.syncCompletedStories(snapshotStoryIds);
    await _achievementService.completeStory(storyIdForAchievements);
    final afterState = await _achievementService.incrementStoryCount(
      totalStoriesInCatalog: total,
      calmPercent: calmPercent,
      anxietyPercent: anxietyPercent,
      finishedInOneSession: !resumedFromSavedProgress,
    );
    final rawUnlocked = _getNewlyUnlockedAchievements(beforeState, afterState);
    return _filterAndRememberAnnounced(rawUnlocked);
  }

  
  Future<void> discardStoryProgress({
    required String resumeStoryId,
    required String storyTitle,
    required String topic,
  }) async {
    final current = await load();
    final normalizedTopic = _normalizeTopic(topic, storyTitle);
    final storyId = _resolveResumeStoryId(
          resumeStoryId: resumeStoryId,
          storyTitle: storyTitle,
          normalizedTopic: normalizedTopic,
          rawTopic: topic,
        ) ??
        StoryResumeCatalog.storyIdFromNormalizedTopic(normalizedTopic);
    if (storyId == null) return;

    final map = Map<String, int>.from(current.inProgressStories);
    map.remove(storyId);

    final clearCurrent = current.currentTopic == normalizedTopic;
    final next = current.copyWith(
      inProgressStories: map,
      clearCurrent: clearCurrent,
    );
    await save(next);
  }

  
  
  Future<void> seedAnnouncedWithCurrentlyUnlocked() async {
    final syncedState = await _achievementService.loadState();
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

  String? _resolveResumeStoryId({
    String? resumeStoryId,
    required String storyTitle,
    required String normalizedTopic,
    required String rawTopic,
  }) {
    final trimmed = resumeStoryId?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return StoryResumeCatalog.storyIdFromStoryTitleAndTopic(
          storyTitle: storyTitle,
          topic: normalizedTopic,
        ) ??
        StoryResumeCatalog.storyIdFromStoryTitleAndTopic(
          storyTitle: storyTitle,
          topic: rawTopic,
        ) ??
        StoryResumeCatalog.storyIdFromNormalizedTopic(normalizedTopic) ??
        StoryResumeCatalog.storyIdFromNormalizedTopic(rawTopic);
  }

  String _normalizeTopic(String topic, String storyTitle) {
    final raw = topic.trim().toLowerCase();

    if (raw.contains('depression')) return 'depression';
    if (raw.contains('loneliness')) return 'loneliness';
    if (raw.contains('grief')) return 'grief';
    if (raw.contains('anxiety')) return 'anxiety';
    if (raw.contains('failure')) return 'failure';

    final title = storyTitle.trim().toLowerCase();

    if (title.contains('what still remains')) return 'depression';
    if (title.contains('alone, again')) return 'loneliness';
    if (title.contains('the space you left')) return 'grief';
    if (title.contains('the day after')) return 'grief';
    if (title.contains('too loud inside')) return 'anxiety';
    if (title.contains('almost there')) return 'failure';

    return raw;
  }

  Future<void> _syncToFirebase(StoryProgressData data) async {
    final user = UserSession.currentUser;
    if (user == null || user.uid.isEmpty || user.idToken.isEmpty) return;

    final uri = Uri.parse(
      '$_docBase/${user.uid}?key=${FirebaseProjectConfig.apiKey}&updateMask.fieldPaths=storyProgressJson',
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
        Uri.parse('$_docBase/${user.uid}?key=${FirebaseProjectConfig.apiKey}'),
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

    final fields = await FirestoreUserDocumentRepository.fetchFields(
      uid: user.uid,
      idToken: user.idToken,
    );
    if (fields == null) return null;

    final extraInProgress = _inProgressFromFirestoreRawFields(fields);
    final legacyCompletedStoryIds = _finishedStoryIdsFromLegacyCompletedStories(
      fields['completedStories'],
    );
    final legacyFinishedTopics = legacyCompletedStoryIds
        .map(_topicFromStoryId)
        .whereType<String>()
        .toSet();

    final rawProgress =
        (fields['storyProgressJson'] as Map<String, dynamic>?)?['stringValue']
            as String?;

    if (rawProgress != null && rawProgress.isNotEmpty) {
      try {
        final progressJson = jsonDecode(rawProgress) as Map<String, dynamic>;
        final base = StoryProgressData.fromJson(progressJson);
        if (extraInProgress.isEmpty && legacyFinishedTopics.isEmpty) return base;
        final mergedFinished = {
          ...base.finishedStories,
          ...legacyFinishedTopics,
        }.toList();
        return base.copyWith(
          inProgressStories: _mergeInProgressSceneMaps(
            base.inProgressStories,
            extraInProgress,
          ),
          finishedStories: mergedFinished,
        );
      } catch (_) {
        
      }
    }

    if (extraInProgress.isEmpty && legacyFinishedTopics.isEmpty) return null;
    return StoryProgressData(
      inProgressStories: extraInProgress,
      finishedStories: legacyFinishedTopics.toList(),
    );
  }

  
  
  Map<String, int> _inProgressFromFirestoreRawFields(
    Map<String, dynamic> fields,
  ) {
    final merged = <String, int>{};
    void add(Map<String, int> m) {
      m.forEach((k, v) {
        final prev = merged[k] ?? 0;
        merged[k] = v > prev ? v : prev;
      });
    }

    add(_parseFirestoreDocumentMap(fields['inProgressStories']));
    add(_parseFirestoreDocumentMap(fields['in_progress_stories']));
    add(_parseInProgressFromJsonStringField(fields['inProgressStories']));
    add(_parseInProgressFromJsonStringField(fields['inProgressStoriesJson']));
    add(_parseLegacyStoryProgressMap(fields['storyProgress']));

    final blob = _decodeStoryProgressStringField(fields['storyProgressJson']);
    if (blob != null) {
      add(_inProgressEmbeddedInStoryJson(blob));
    }
    return merged;
  }

  Map<String, int> _parseFirestoreDocumentMap(Object? rawInProgress) {
    if (rawInProgress is Map) {
      final raw = Map<String, dynamic>.from(rawInProgress);
      final mapValue = raw['mapValue'];
      if (mapValue is Map) {
        final inner = Map<String, dynamic>.from(mapValue);
        final fieldEntries = inner['fields'];
        if (fieldEntries is Map) {
          final fieldsMap = Map<String, dynamic>.from(fieldEntries);
          final out = <String, int>{};
          fieldsMap.forEach((storyId, rawScene) {
            final scene = _parseSceneValue(rawScene);
            if (scene != null) out[storyId.toString()] = scene;
          });
          if (out.isNotEmpty) return out;
        }
      }

      final direct = <String, int>{};
      raw.forEach((storyId, rawScene) {
        if (storyId == 'mapValue' || storyId == 'stringValue') return;
        final scene = _parseSceneValue(rawScene);
        if (scene != null) direct[storyId.toString()] = scene;
      });
      if (direct.isNotEmpty) return direct;
    }
    return const <String, int>{};
  }

  int? _parseSceneValue(Object? rawScene) {
    return _parseFirestoreInt(rawScene) ?? _parseLooseInt(rawScene);
  }

  Map<String, int> _parseLegacyStoryProgressMap(Object? rawStoryProgress) {
    if (rawStoryProgress is! Map) return const <String, int>{};
    final parsed = _parseFirestoreDocumentMap(rawStoryProgress);
    if (parsed.isEmpty) return const <String, int>{};
    final out = <String, int>{};
    parsed.forEach((rawKey, scene) {
      if (scene < 1) return;
      final storyId = _toStoryId(rawKey);
      if (storyId == null || storyId.isEmpty) return;
      final prev = out[storyId] ?? 0;
      out[storyId] = scene > prev ? scene : prev;
    });
    return out;
  }

  Set<String> _finishedStoryIdsFromLegacyCompletedStories(Object? rawCompleted) {
    if (rawCompleted is! Map) return const <String>{};
    final parsed = _parseFirestoreDocumentMap(rawCompleted);
    final out = <String>{};
    parsed.forEach((rawKey, value) {
      if (value != 1) return;
      final storyId = _toStoryId(rawKey);
      if (storyId != null && storyId.isNotEmpty) {
        out.add(storyId);
      }
    });
    return out;
  }

  Map<String, int> _parseInProgressFromJsonStringField(Object? rawField) {
    final jsonText = _parseFirestoreString(rawField);
    if (jsonText == null || jsonText.isEmpty) return const <String, int>{};
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) return const <String, int>{};
      final map = Map<String, dynamic>.from(decoded);
      final out = <String, int>{};
      map.forEach((storyId, rawScene) {
        final scene = _parseLooseInt(rawScene);
        if (scene != null) out[storyId] = scene;
      });
      return out;
    } catch (_) {
      return const <String, int>{};
    }
  }

  Map<String, dynamic>? _decodeStoryProgressStringField(Object? rawField) {
    final jsonText = _parseFirestoreString(rawField);
    if (jsonText == null || jsonText.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  Map<String, int> _inProgressEmbeddedInStoryJson(Map<String, dynamic> decoded) {
    final fromMap = <String, int>{};
    final rawMap = decoded['inProgressStories'];
    if (rawMap is Map) {
      rawMap.forEach((k, v) {
        final scene = _parseLooseInt(v);
        if (scene != null && scene > 0) fromMap[k.toString()] = scene;
      });
    }
    final topic = decoded['currentTopic']?.toString();
    final storyTitle = decoded['currentStoryTitle']?.toString();
    final currentScene = _parseLooseInt(decoded['currentScene']);
    if (currentScene != null && currentScene > 0) {
      final storyId = StoryResumeCatalog.storyIdFromStoryTitleAndTopic(
            storyTitle: storyTitle ?? '',
            topic: topic ?? '',
          ) ??
          StoryResumeCatalog.storyIdFromNormalizedTopic(topic ?? '');
      if (storyId != null) fromMap.putIfAbsent(storyId, () => currentScene);
    }
    return fromMap;
  }

  String? _parseFirestoreString(Object? rawField) {
    if (rawField is Map) {
      final m = Map<String, dynamic>.from(rawField);
      final stringValue = m['stringValue'];
      if (stringValue is String && stringValue.isNotEmpty) {
        return stringValue;
      }
    }
    if (rawField is String && rawField.isNotEmpty) return rawField;
    return null;
  }

  int? _parseFirestoreInt(Object? raw) {
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      final integerValue = m['integerValue'];
      if (integerValue is String) return int.tryParse(integerValue);
      if (integerValue is num) return integerValue.toInt();

      final stringValue = m['stringValue'];
      if (stringValue is String) return int.tryParse(stringValue);

      final doubleValue = m['doubleValue'];
      if (doubleValue is num) return doubleValue.round();

      final boolValue = m['booleanValue'];
      if (boolValue is bool) return boolValue ? 1 : 0;
    }
    return null;
  }

  int? _parseLooseInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is double) return raw.round();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  String? _toStoryId(String rawKey) {
    final normalized = rawKey.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (StoryResumeCatalog.titles.containsKey(normalized)) return normalized;
    return StoryResumeCatalog.storyIdFromNormalizedTopic(normalized);
  }

  String? _topicFromStoryId(String storyId) {
    switch (storyId) {
      case 'the_day_after':
        return 'grief';
      case 'what_still_remains':
        return 'depression';
      case 'alone_again':
        return 'loneliness';
      case 'almost_there':
        return 'failure';
      case 'too_loud_inside':
        return 'anxiety';
      default:
        return null;
    }
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
