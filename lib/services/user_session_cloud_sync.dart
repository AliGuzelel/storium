import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../garden/garden_storage.dart';
import '../models/user_session.dart';
import '../providers/settings_manager.dart';
import 'achievement_service.dart';
import 'firestore_user_document_repository.dart';
import 'settings_service.dart';
import 'story_progress_service.dart';

/// Pulls `users/{uid}` optional JSON blobs after login / cold start.
///
/// Firestore fields: `settingsJson`, `gardenJson`, `achievementStateJson`,
/// `storyProgressJson` (story service already consumes the last on [StoryProgressService.load]).
class UserSessionCloudSync {
  UserSessionCloudSync._();

  static String? _stringField(Map<String, dynamic>? fields, String name) {
    if (fields == null) return null;
    final raw = fields[name];
    if (raw is! Map<String, dynamic>) return null;
    final v = raw['stringValue'];
    if (v is! String || v.isEmpty) return null;
    return v;
  }

  static String _scopedKey(String base, String uid) => '${base}_$uid';

  static Future<void> hydrateIfSignedIn({
    SettingsManager? settingsManager,
  }) async {
    final u = UserSession.currentUser;
    if (u == null || u.uid.isEmpty || u.idToken.isEmpty) return;

    try {
      final fields = await FirestoreUserDocumentRepository.fetchFields(
        uid: u.uid,
        idToken: u.idToken,
      );
      if (fields == null) return;

      final settingsRaw = _stringField(fields, 'settingsJson');
      if (settingsRaw != null) {
        await SettingsService().importFromRemoteString(settingsRaw);
        await settingsManager?.reloadFromDisk();
      }

      final gardenRaw = _stringField(fields, 'gardenJson');
      if (gardenRaw != null) {
        await GardenStorage.importFromRemoteJsonString(
          gardenRaw,
          uidScope: u.uid,
        );
      }

      final achRaw = _stringField(fields, 'achievementStateJson');
      if (achRaw != null) {
        await AchievementService().importFromRemoteString(achRaw);
      }

      final mySpaceRaw = _stringField(fields, 'mySpaceJson');
      if (mySpaceRaw != null) {
        await _hydrateMySpacePrefs(uid: u.uid, raw: mySpaceRaw);
      }

      final dailyRaw = _stringField(fields, 'dailyCheckinJson');
      if (dailyRaw != null) {
        await _hydrateDailyCheckinPrefs(uid: u.uid, raw: dailyRaw);
      }

      await StoryProgressService().load();
    } catch (e, st) {
      debugPrint('UserSessionCloudSync.hydrateIfSignedIn: $e\n$st');
    }
  }

  static Future<void> _hydrateMySpacePrefs({
    required String uid,
    required String raw,
  }) async {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_scopedKey('my_space_saved_images_v2', uid), raw);
    } catch (_) {}
  }

  static Future<void> _hydrateDailyCheckinPrefs({
    required String uid,
    required String raw,
  }) async {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final map = Map<String, dynamic>.from(decoded);
      final prefs = await SharedPreferences.getInstance();

      final selectedDate = map['selectedDate'] as String?;
      if (selectedDate != null && selectedDate.isNotEmpty) {
        await prefs.setString(
          _scopedKey('daily_questions_selected_date', uid),
          selectedDate,
        );
      }
      final lastCompleted = map['lastCompletedDate'] as String?;
      if (lastCompleted != null && lastCompleted.isNotEmpty) {
        await prefs.setString(
          _scopedKey('daily_questions_last_completed_date', uid),
          lastCompleted,
        );
      }
      final selectedQuestions = (map['selectedQuestions'] as List<dynamic>?)
          ?.whereType<String>()
          .toList();
      if (selectedQuestions != null && selectedQuestions.isNotEmpty) {
        await prefs.setStringList(
          _scopedKey('daily_questions_selected_list', uid),
          selectedQuestions,
        );
      }
      final previousQuestions = (map['previousQuestions'] as List<dynamic>?)
          ?.whereType<String>()
          .toList();
      if (previousQuestions != null && previousQuestions.isNotEmpty) {
        await prefs.setStringList(
          _scopedKey('daily_questions_previous_selected_list', uid),
          previousQuestions,
        );
      }
    } catch (_) {}
  }
}
