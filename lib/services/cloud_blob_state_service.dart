import 'package:flutter/foundation.dart';

import '../models/user_session.dart';
import 'firestore_user_document_repository.dart';

/// Small helper for storing feature JSON blobs under `users/{uid}`.
class CloudBlobStateService {
  CloudBlobStateService._();

  static Future<String?> fetch(String fieldPath) async {
    final u = UserSession.currentUser;
    if (u == null || u.uid.isEmpty || u.idToken.isEmpty) return null;
    try {
      return await FirestoreUserDocumentRepository.fetchStringField(
        uid: u.uid,
        idToken: u.idToken,
        fieldPath: fieldPath,
      );
    } catch (e, st) {
      debugPrint('CloudBlobStateService.fetch($fieldPath): $e\n$st');
      return null;
    }
  }

  static Future<void> push(String fieldPath, String jsonValue) async {
    final u = UserSession.currentUser;
    if (u == null || u.uid.isEmpty || u.idToken.isEmpty) return;
    try {
      await FirestoreUserDocumentRepository.patchStringFields(
        uid: u.uid,
        idToken: u.idToken,
        stringFields: {fieldPath: jsonValue},
      );
    } catch (e, st) {
      debugPrint('CloudBlobStateService.push($fieldPath): $e\n$st');
    }
  }
}
