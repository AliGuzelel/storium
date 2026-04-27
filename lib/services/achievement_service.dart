import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement_model.dart';
import '../models/user_session.dart';
import 'firestore_user_document_repository.dart';

class AchievementService {
  static const String _storageKey = 'achievement_state';
  static const int calmUnlockThreshold = 80;
  static const int anxietyUnlockThreshold = 60;

  static const Map<String, int> _storyMilestones = {
    'first_story': 1,
    'two_stories': 2,
    'three_stories': 3,
    'four_stories': 4,
    'five_stories': 5,
  };
  static const Map<String, int> _plantMilestones = {
    'first_plant': 1,
    'three_plants': 3,
    'six_plants': 6,
  };
  static const Map<String, int> _activeDayMilestones = {
    'returning': 2,
    'still_here': 3,
  };

  static const Map<String, ({
    String title,
    String description,
    String hint,
    IconData icon,
    AchievementSection section,
  })>
  _achievementCatalog = {
    'first_story': (
      title: 'First Story',
      description: 'Complete your first story in Storium.',
      hint: 'Finish your first story',
      icon: Icons.auto_stories_rounded,
      section: AchievementSection.stories,
    ),
    'two_stories': (
      title: 'Two Stories',
      description: 'Complete two stories.',
      hint: 'Complete 2 different stories',
      icon: Icons.menu_book_rounded,
      section: AchievementSection.stories,
    ),
    'three_stories': (
      title: 'Three Stories',
      description: 'Complete three stories.',
      hint: 'Complete 3 different stories',
      icon: Icons.collections_bookmark_rounded,
      section: AchievementSection.stories,
    ),
    'four_stories': (
      title: 'Four Stories',
      description: 'Complete four stories.',
      hint: 'Complete 4 different stories',
      icon: Icons.library_books_rounded,
      section: AchievementSection.stories,
    ),
    'five_stories': (
      title: 'Five Stories',
      description: 'Complete five stories.',
      hint: 'Complete 5 different stories',
      icon: Icons.bookmarks_rounded,
      section: AchievementSection.stories,
    ),
    'all_stories': (
      title: 'All Stories',
      description: 'Complete every story in the app.',
      hint: 'Finish all available stories',
      icon: Icons.workspace_premium_rounded,
      section: AchievementSection.stories,
    ),
    'calm_80': (
      title: 'Calm 80',
      description: 'Finish a story with calm at 80% or higher.',
      hint: 'Reach a calm ending (80%+)',
      icon: Icons.self_improvement_rounded,
      section: AchievementSection.emotions,
    ),
    'high_anxiety': (
      title: 'High Anxiety',
      description: 'Reach high anxiety in a story outcome.',
      hint: 'Finish with high anxiety',
      icon: Icons.psychology_alt_rounded,
      section: AchievementSection.emotions,
    ),
    'balance': (
      title: 'Balance',
      description: 'Unlock both Calm 80 and High Anxiety.',
      hint: 'Unlock calm and anxiety endings',
      icon: Icons.balance_rounded,
      section: AchievementSection.emotions,
    ),
    'first_plant': (
      title: 'First Plant',
      description: 'Grow your first plant to full.',
      hint: 'Grow your first plant',
      icon: Icons.local_florist_rounded,
      section: AchievementSection.garden,
    ),
    'three_plants': (
      title: 'Three Plants',
      description: 'Grow three plants to full.',
      hint: 'Grow 3 plants',
      icon: Icons.yard_rounded,
      section: AchievementSection.garden,
    ),
    'six_plants': (
      title: 'Six Plants',
      description: 'Grow six plants to full.',
      hint: 'Grow 6 plants',
      icon: Icons.park_rounded,
      section: AchievementSection.garden,
    ),
    'returning': (
      title: 'Returning',
      description: 'Be active for at least 2 days.',
      hint: 'Come back another day',
      icon: Icons.event_repeat_rounded,
      section: AchievementSection.activity,
    ),
    'still_here': (
      title: 'Still Here',
      description: 'Be active for at least 3 days.',
      hint: 'Come back for 3 different days',
      icon: Icons.favorite_rounded,
      section: AchievementSection.activity,
    ),
    'stayed': (
      title: 'Stayed',
      description: 'Finish a story in one session.',
      hint: 'Finish a story in one sitting',
      icon: Icons.hourglass_bottom_rounded,
      section: AchievementSection.activity,
    ),
    'continued': (
      title: 'Continued',
      description: 'Resume a story and continue later.',
      hint: 'Continue a story later',
      icon: Icons.play_circle_fill_rounded,
      section: AchievementSection.activity,
    ),
  };

  String _prefsKeyForUser() {
    final u = UserSession.currentUser;
    if (u == null || u.uid.isEmpty) {
      return '${_storageKey}_guest';
    }
    return '${_storageKey}_${u.uid}';
  }

  Future<AchievementState> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _prefsKeyForUser();
    final local = _loadLocalState(prefs, key);
    final user = UserSession.currentUser;
    if (user == null || user.uid.isEmpty || user.idToken.isEmpty) {
      return local;
    }
    final remote = await fetchUserDataFromFirestore();
    final merged = _mergePreferUnlocked(local, remote);
    await _saveLocalState(merged);
    return merged;
  }

  Future<void> _saveLocalState(AchievementState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyForUser(), jsonEncode(state.toJson()));
  }

  AchievementState _loadLocalState(SharedPreferences prefs, String key) {
    var raw = prefs.getString(key);
    if ((raw == null || raw.isEmpty) && !key.endsWith('_guest')) {
      final legacy = prefs.getString(_storageKey);
      if (legacy != null && legacy.isNotEmpty) {
        raw = legacy;
      }
    }
    if (raw == null || raw.isEmpty) return AchievementState.empty();
    try {
      return AchievementState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AchievementState.empty();
    }
  }

  AchievementState _mergePreferUnlocked(
    AchievementState local,
    AchievementState remote,
  ) {
    final mergedAchievements = <String, bool>{};
    for (final id in _achievementCatalog.keys) {
      mergedAchievements[id] =
          (local.achievements[id] ?? false) || (remote.achievements[id] ?? false);
    }
    final mergedStats = UserStats(
      storiesCompleted: local.stats.storiesCompleted > remote.stats.storiesCompleted
          ? local.stats.storiesCompleted
          : remote.stats.storiesCompleted,
      plantsGrown: local.stats.plantsGrown > remote.stats.plantsGrown
          ? local.stats.plantsGrown
          : remote.stats.plantsGrown,
      daysActive: local.stats.daysActive > remote.stats.daysActive
          ? local.stats.daysActive
          : remote.stats.daysActive,
      continuedStories:
          local.stats.continuedStories > remote.stats.continuedStories
          ? local.stats.continuedStories
          : remote.stats.continuedStories,
      lastVisitDayKey: local.stats.lastVisitDayKey ?? remote.stats.lastVisitDayKey,
    );
    final mergedCompletedStories = {
      ...local.completedStoriesList.map((e) => e.toLowerCase()),
      ...remote.completedStoriesList.map((e) => e.toLowerCase()),
    }.toList()
      ..sort();
    return AchievementState(
      stats: mergedStats,
      completedStoriesList: mergedCompletedStories,
      achievements: mergedAchievements,
    );
  }

  Future<AchievementState> fetchUserDataFromFirestore() async {
    final u = UserSession.currentUser;
    if (u == null || u.uid.isEmpty || u.idToken.isEmpty) {
      return AchievementState.empty();
    }
    try {
      final statsRaw = await FirestoreUserDocumentRepository.fetchDecodedField(
        uid: u.uid,
        idToken: u.idToken,
        fieldPath: 'stats',
      );
      final achievementsRaw =
          await FirestoreUserDocumentRepository.fetchDecodedField(
            uid: u.uid,
            idToken: u.idToken,
            fieldPath: 'achievements',
          );
      final completedStoriesRaw =
          await FirestoreUserDocumentRepository.fetchDecodedField(
            uid: u.uid,
            idToken: u.idToken,
            fieldPath: 'completedStoriesList',
          );
      final statsMap = statsRaw is Map
          ? Map<String, dynamic>.from(statsRaw)
          : const <String, dynamic>{};
      final achievementsMap = <String, bool>{
        for (final id in _achievementCatalog.keys) id: false,
      };
      if (achievementsRaw is Map) {
        for (final e in achievementsRaw.entries) {
          if (_achievementCatalog.containsKey(e.key)) {
            achievementsMap[e.key] = e.value == true;
          }
        }
      }
      final completedStoriesList = (completedStoriesRaw is List
              ? completedStoriesRaw
              : const <dynamic>[])
          .map((e) => e.toString().trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      return AchievementState(
        stats: UserStats.fromJson(statsMap),
        completedStoriesList: completedStoriesList,
        achievements: achievementsMap,
      );
    } catch (e, st) {
      debugPrint('AchievementService.fetchUserDataFromFirestore: $e\n$st');
      return AchievementState.empty();
    }
  }

  /// Backward-compatible import for legacy `achievementStateJson` blob.
  Future<void> importFromRemoteString(String jsonStr) async {
    try {
      final parsed = AchievementState.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
      await saveState(parsed, pushToCloud: false);
    } catch (e, st) {
      debugPrint('AchievementService.importFromRemoteString: $e\n$st');
    }
  }

  Future<void> saveState(
    AchievementState state, {
    bool pushToCloud = true,
  }) async {
    await _saveLocalState(state);
    if (!pushToCloud) return;
    final u = UserSession.currentUser;
    if (u == null || u.uid.isEmpty || u.idToken.isEmpty) return;
    try {
      await FirestoreUserDocumentRepository.patchDynamicFields(
        uid: u.uid,
        idToken: u.idToken,
        fields: {
          'completedStoriesList': state.completedStoriesList,
          'stats': state.stats.toJson(),
          'achievements': state.achievements,
        },
      );
    } catch (e, st) {
      debugPrint('AchievementService.saveState cloud: $e\n$st');
    }
  }

  Map<String, bool> checkAndUnlockAchievements({
    required AchievementState userData,
    required int totalStoriesInCatalog,
    int? calmPercent,
    int? anxietyPercent,
    bool unlockedStayed = false,
    bool unlockedContinued = false,
  }) {
    final current = Map<String, bool>.from(userData.achievements);
    final stats = userData.stats;
    for (final entry in _storyMilestones.entries) {
      if (stats.storiesCompleted >= entry.value) current[entry.key] = true;
    }
    if (stats.storiesCompleted >= totalStoriesInCatalog && totalStoriesInCatalog > 0) {
      current['all_stories'] = true;
    }
    if ((calmPercent ?? -1) >= calmUnlockThreshold) current['calm_80'] = true;
    if ((anxietyPercent ?? -1) >= anxietyUnlockThreshold) {
      current['high_anxiety'] = true;
    }
    final hasBalancedOutcome =
        calmPercent != null &&
        anxietyPercent != null &&
        calmPercent > 0 &&
        anxietyPercent > 0 &&
        (calmPercent - anxietyPercent).abs() <= 10;
    if (current['calm_80'] == true && current['high_anxiety'] == true) {
      current['balance'] = true;
    }
    if (hasBalancedOutcome) {
      current['balance'] = true;
    }
    for (final entry in _plantMilestones.entries) {
      if (stats.plantsGrown >= entry.value) current[entry.key] = true;
    }
    for (final entry in _activeDayMilestones.entries) {
      if (stats.daysActive >= entry.value) current[entry.key] = true;
    }
    if (unlockedStayed) current['stayed'] = true;
    if (unlockedContinued || stats.continuedStories > 0) current['continued'] = true;
    return current;
  }

  /// Reconciles unique story IDs from progress snapshots (prevents stats mismatch).
  Future<void> syncCompletedStories(Iterable<String> storyIds) async {
    final normalized = storyIds
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
    if (normalized.isEmpty) return;

    final state = await loadState();
    final merged = {
      ...state.completedStoriesList.map((e) => e.toLowerCase()),
      ...normalized,
    }.toList()
      ..sort();
    if (merged.length == state.completedStoriesList.length &&
        merged.every(state.completedStoriesList.contains)) {
      return;
    }

    final nextStats = state.stats.copyWith(
      storiesCompleted:
          merged.length > state.stats.storiesCompleted ? merged.length : state.stats.storiesCompleted,
    );
    final next = state.copyWith(
      completedStoriesList: merged,
      stats: nextStats,
    );
    await saveState(next);
  }

  /// No unlocked achievement is ever overwritten from true to false.
  Future<AchievementState> updateAchievementsSafely({
    required AchievementState state,
    required Map<String, bool> nextAchievements,
    bool pushToCloud = true,
  }) async {
    final merged = <String, bool>{};
    for (final id in _achievementCatalog.keys) {
      final existing = state.achievements[id] ?? false;
      final incoming = nextAchievements[id] ?? false;
      merged[id] = existing || incoming;
    }
    final updated = state.copyWith(achievements: merged);
    await saveState(updated, pushToCloud: pushToCloud);
    return updated;
  }

  Future<void> completeStory(String storyId) async {
    await _completeStoryInternal(
      storyId: storyId,
      totalStoriesInCatalog: 0,
    );
  }

  Future<AchievementState> _completeStoryInternal({
    required String storyId,
    required int totalStoriesInCatalog,
    int? calmPercent,
    int? anxietyPercent,
    bool finishedInOneSession = false,
  }) async {
    final normalizedId = storyId.trim().toLowerCase();
    if (normalizedId.isEmpty) {
      return loadState();
    }

    final user = UserSession.currentUser;
    if (user == null || user.uid.isEmpty) {
      return loadState();
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        final data = snap.data() ?? const <String, dynamic>{};
        final existing = (data['completedStoriesList'] as List<dynamic>? ?? const [])
            .map((e) => e.toString().trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toSet();
        if (existing.contains(normalizedId)) return;
        tx.set(
          docRef,
          <String, dynamic>{
            'completedStoriesList': FieldValue.arrayUnion(<String>[normalizedId]),
            'stats': <String, dynamic>{
              'storiesCompleted': FieldValue.increment(1),
            },
          },
          SetOptions(merge: true),
        );
      });
    } catch (e, st) {
      debugPrint('AchievementService.completeStory transaction: $e\n$st');
    }

    final remote = await fetchUserDataFromFirestore();
    final local = await loadState();
    final state = _mergePreferUnlocked(local, remote);
    // Fallback safety: even if transaction is unavailable, keep unique completion
    // locally (and via REST save) so achievements still unlock.
    final storySet = state.completedStoriesList.map((e) => e.toLowerCase()).toSet()
      ..add(normalizedId);
    final normalizedCompletedList = storySet.toList()..sort();
    final uniqueCount = normalizedCompletedList.length;
    final nextStats = state.stats.copyWith(
      storiesCompleted: uniqueCount > state.stats.storiesCompleted
          ? uniqueCount
          : state.stats.storiesCompleted,
    );
    final withStats = state.copyWith(
      stats: nextStats,
      completedStoriesList: normalizedCompletedList,
    );
    final unlocked = checkAndUnlockAchievements(
      userData: withStats,
      totalStoriesInCatalog: totalStoriesInCatalog,
      calmPercent: calmPercent,
      anxietyPercent: anxietyPercent,
      unlockedStayed: finishedInOneSession,
    );
    final updated = await updateAchievementsSafely(
      state: withStats,
      nextAchievements: unlocked,
      pushToCloud: false,
    );
    await saveState(updated);
    return updated;
  }

  Future<AchievementState> incrementStoryCount({
    required int totalStoriesInCatalog,
    int? calmPercent,
    int? anxietyPercent,
    bool finishedInOneSession = false,
  }) async {
    // Backward-compat path: evaluate unlocks without incrementing storiesCompleted.
    final state = await loadState();
    final unlocked = checkAndUnlockAchievements(
      userData: state,
      totalStoriesInCatalog: totalStoriesInCatalog,
      calmPercent: calmPercent,
      anxietyPercent: anxietyPercent,
      unlockedStayed: finishedInOneSession,
    );
    final updated = await updateAchievementsSafely(
      state: state,
      nextAchievements: unlocked,
      pushToCloud: false,
    );
    await saveState(updated);
    return updated;
  }

  Future<AchievementState> incrementPlantCount() async {
    final state = await loadState();
    final nextStats = state.stats.copyWith(
      plantsGrown: state.stats.plantsGrown + 1,
    );
    final withStats = state.copyWith(stats: nextStats);
    final unlocked = checkAndUnlockAchievements(
      userData: withStats,
      totalStoriesInCatalog: 0,
    );
    final updated = await updateAchievementsSafely(
      state: withStats,
      nextAchievements: unlocked,
      pushToCloud: false,
    );
    await saveState(updated);
    return updated;
  }

  Future<AchievementState> trackDailyVisit({DateTime? now}) async {
    final ts = now ?? DateTime.now();
    final dayKey = '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}';
    final state = await loadState();
    if (state.stats.lastVisitDayKey == dayKey) return state;
    final nextStats = state.stats.copyWith(
      daysActive: state.stats.daysActive + 1,
      lastVisitDayKey: dayKey,
    );
    final withStats = state.copyWith(stats: nextStats);
    final unlocked = checkAndUnlockAchievements(
      userData: withStats,
      totalStoriesInCatalog: 0,
    );
    final updated = await updateAchievementsSafely(
      state: withStats,
      nextAchievements: unlocked,
      pushToCloud: false,
    );
    await saveState(updated);
    return updated;
  }

  Future<AchievementState> trackContinueUsage() async {
    final state = await loadState();
    final nextStats = state.stats.copyWith(
      continuedStories: state.stats.continuedStories + 1,
    );
    final withStats = state.copyWith(stats: nextStats);
    final unlocked = checkAndUnlockAchievements(
      userData: withStats,
      totalStoriesInCatalog: 0,
      unlockedContinued: true,
    );
    final updated = await updateAchievementsSafely(
      state: withStats,
      nextAchievements: unlocked,
      pushToCloud: false,
    );
    await saveState(updated);
    return updated;
  }

  List<AchievementModel> buildAchievementModels(AchievementState state) {
    return _achievementCatalog.entries
        .map(
          (e) => AchievementModel(
            id: e.key,
            title: e.value.title,
            description: e.value.description,
            hint: e.value.hint,
            icon: e.value.icon,
            unlocked: state.achievements[e.key] ?? false,
            section: e.value.section,
          ),
        )
        .toList();
  }
}
