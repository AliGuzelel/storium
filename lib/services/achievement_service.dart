import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement_model.dart';
import '../models/story_progress.dart';
import '../models/user_session.dart';
import 'firestore_user_document_repository.dart';

class AchievementService {
  static const String _storageKey = 'achievement_state';

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
    var raw = prefs.getString(key);

    if ((raw == null || raw.isEmpty) && !key.endsWith('_guest')) {
      final legacy = prefs.getString(_storageKey);
      if (legacy != null && legacy.isNotEmpty) {
        raw = legacy;
        await prefs.setString(key, legacy);
      }
    }

    if (raw == null || raw.isEmpty) {
      return AchievementState.empty();
    }

    try {
      return AchievementState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AchievementState.empty();
    }
  }

  Future<void> importFromRemoteString(String jsonStr) async {
    try {
      final state =
          AchievementState.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      await saveState(state, pushToCloud: false);
    } catch (e, st) {
      debugPrint('AchievementService.importFromRemoteString: $e\n$st');
    }
  }

  Future<void> saveState(
    AchievementState state, {
    bool pushToCloud = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyForUser(), jsonEncode(state.toJson()));

    if (pushToCloud) {
      final u = UserSession.currentUser;
      if (u != null && u.uid.isNotEmpty && u.idToken.isNotEmpty) {
        try {
          await FirestoreUserDocumentRepository.patchStringFields(
            uid: u.uid,
            idToken: u.idToken,
            stringFields: {
              'achievementStateJson': jsonEncode(state.toJson()),
            },
          );
        } catch (e, st) {
          debugPrint('AchievementService.saveState cloud: $e\n$st');
        }
      }
    }
  }

  Future<AchievementState> syncWithStoryProgress(
    StoryProgressData progress,
  ) async {
    final current = await loadState();

    final completedStories = Map<String, bool>.from(current.completedStories);
    final achievements = Map<String, bool>.from(current.achievements);

    final finished = progress.finishedStories
        .map((e) => e.toLowerCase())
        .toSet();

    completedStories['depression'] = finished.contains('depression');
    completedStories['loneliness'] = finished.contains('loneliness');
    completedStories['grief'] = finished.contains('grief');

    achievements['what_remains'] = completedStories['depression'] == true;
    achievements['still_here'] = completedStories['loneliness'] == true;
    achievements['shadow_walker'] = completedStories['grief'] == true;

    achievements['first_step'] =
        completedStories.values.where((v) => v).isNotEmpty;

    achievements['story_seeker'] =
        completedStories.values.where((v) => v).length >= 2;

    achievements['resilient_soul'] = completedStories.values.every(
      (v) => v == true,
    );

    achievements['gentle_heart'] =
        progress.lastStoryCalm >= progress.lastStoryAnxiety &&
        (progress.lastStoryCalm != 0 || progress.lastStoryAnxiety != 0);

    final updated = AchievementState(
      completedStories: completedStories,
      achievements: achievements,
    );

    await saveState(updated);
    return updated;
  }

  List<AchievementModel> buildAchievementModels(AchievementState state) {
    final a = state.achievements;

    return [
      AchievementModel(
        id: 'shadow_walker',
        title: 'Shadow Walker',
        description: 'Completed The Day After and faced grief with courage.',
        icon: '🖤',
        unlocked: a['shadow_walker'] ?? false,
      ),
      AchievementModel(
        id: 'still_here',
        title: 'Still Here',
        description: 'Completed Alone, Again and made it through loneliness.',
        icon: '🌙',
        unlocked: a['still_here'] ?? false,
      ),
      AchievementModel(
        id: 'what_remains',
        title: 'What Remains',
        description: 'Completed What Still Remains and faced heavy emotions.',
        icon: '🍂',
        unlocked: a['what_remains'] ?? false,
      ),
      AchievementModel(
        id: 'first_step',
        title: 'First Step',
        description: 'Completed your first story in Storium.',
        icon: '✨',
        unlocked: a['first_step'] ?? false,
      ),
      AchievementModel(
        id: 'story_seeker',
        title: 'Story Seeker',
        description: 'Completed two different stories.',
        icon: '📖',
        unlocked: a['story_seeker'] ?? false,
      ),
      AchievementModel(
        id: 'gentle_heart',
        title: 'Gentle Heart',
        description: 'Finished your last story with more calm than anxiety.',
        icon: '💜',
        unlocked: a['gentle_heart'] ?? false,
      ),
      AchievementModel(
        id: 'resilient_soul',
        title: 'Resilient Soul',
        description: 'Completed all three core stories in Storium.',
        icon: '👑',
        unlocked: a['resilient_soul'] ?? false,
      ),
    ];
  }
}
