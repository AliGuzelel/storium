import 'package:flutter/foundation.dart';

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
        await GardenStorage.importFromRemoteJsonString(gardenRaw);
      }

      final achRaw = _stringField(fields, 'achievementStateJson');
      if (achRaw != null) {
        await AchievementService().importFromRemoteString(achRaw);
      }

      await StoryProgressService().load();
    } catch (e, st) {
      debugPrint('UserSessionCloudSync.hydrateIfSignedIn: $e\n$st');
    }
  }
}
