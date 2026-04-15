import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'firebase_project_config.dart';

/// Reads / patches fields on `users/{uid}` via Firestore REST (same doc as profile).
class FirestoreUserDocumentRepository {
  FirestoreUserDocumentRepository._();

  static String? _stringField(Map<String, dynamic>? fields, String name) {
    if (fields == null) return null;
    final raw = fields[name];
    if (raw is! Map<String, dynamic>) return null;
    final v = raw['stringValue'];
    if (v is! String || v.isEmpty) return null;
    return v;
  }

  /// GET full user document; returns decoded `fields` map or null.
  static Future<Map<String, dynamic>?> fetchFields({
    required String uid,
    required String idToken,
  }) async {
    final uri = FirebaseProjectConfig.userDocumentUri(uid);
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $idToken'},
    );
    if (resp.statusCode == 404) return null;
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      debugPrint('FirestoreUserDocumentRepository.fetchFields: ${resp.statusCode}');
      return null;
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    return decoded['fields'] as Map<String, dynamic>?;
  }

  static Future<String?> fetchStringField({
    required String uid,
    required String idToken,
    required String fieldPath,
  }) async {
    final fields = await fetchFields(uid: uid, idToken: idToken);
    return _stringField(fields, fieldPath);
  }

  /// Patch one or more string fields (JSON blobs, etc.).
  static Future<bool> patchStringFields({
    required String uid,
    required String idToken,
    required Map<String, String> stringFields,
  }) async {
    if (stringFields.isEmpty) return true;
    final masks = stringFields.keys
        .map((k) => 'updateMask.fieldPaths=${Uri.encodeQueryComponent(k)}')
        .join('&');
    final uri = Uri.parse(
      '${FirebaseProjectConfig.userDocumentUri(uid)}&$masks',
    );
    final body = <String, dynamic>{
      'fields': {
        for (final e in stringFields.entries)
          e.key: {'stringValue': e.value},
      },
    };

    var resp = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 404) {
      resp = await http.put(
        FirebaseProjectConfig.userDocumentUri(uid),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(body),
      );
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      debugPrint(
        'FirestoreUserDocumentRepository.patchStringFields: ${resp.statusCode} ${resp.body}',
      );
      return false;
    }
    return true;
  }
}
