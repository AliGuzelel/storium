import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'firebase_project_config.dart';


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

  static dynamic _decodeFirestoreValue(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    if (raw.containsKey('nullValue')) return null;
    if (raw.containsKey('stringValue')) return raw['stringValue'];
    if (raw.containsKey('booleanValue')) return raw['booleanValue'] == true;
    if (raw.containsKey('integerValue')) {
      final v = raw['integerValue'];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }
    if (raw.containsKey('doubleValue')) {
      final v = raw['doubleValue'];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }
    if (raw.containsKey('timestampValue')) return raw['timestampValue'];
    if (raw.containsKey('mapValue')) {
      final mapValue = raw['mapValue'];
      if (mapValue is! Map<String, dynamic>) return <String, dynamic>{};
      final fields = mapValue['fields'];
      if (fields is! Map<String, dynamic>) return <String, dynamic>{};
      return <String, dynamic>{
        for (final entry in fields.entries)
          entry.key: _decodeFirestoreValue(entry.value),
      };
    }
    if (raw.containsKey('arrayValue')) {
      final arrayValue = raw['arrayValue'];
      if (arrayValue is! Map<String, dynamic>) return <dynamic>[];
      final values = arrayValue['values'];
      if (values is! List) return <dynamic>[];
      return values.map(_decodeFirestoreValue).toList();
    }
    return null;
  }

  static Map<String, dynamic> _encodeFirestoreValue(Object? value) {
    if (value == null) return const {'nullValue': null};
    if (value is String) return {'stringValue': value};
    if (value is bool) return {'booleanValue': value};
    if (value is int) return {'integerValue': '$value'};
    if (value is num) return {'doubleValue': value};
    if (value is List) {
      return {
        'arrayValue': {
          'values': value.map(_encodeFirestoreValue).toList(),
        },
      };
    }
    if (value is Map) {
      final fields = <String, dynamic>{};
      value.forEach((k, v) {
        fields[k.toString()] = _encodeFirestoreValue(v);
      });
      return {
        'mapValue': {'fields': fields},
      };
    }
    return {'stringValue': value.toString()};
  }

  
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

  static Future<dynamic> fetchDecodedField({
    required String uid,
    required String idToken,
    required String fieldPath,
  }) async {
    final fields = await fetchFields(uid: uid, idToken: idToken);
    if (fields == null) return null;
    return _decodeFirestoreValue(fields[fieldPath]);
  }

  
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

  
  static Future<bool> patchDynamicFields({
    required String uid,
    required String idToken,
    required Map<String, dynamic> fields,
  }) async {
    if (fields.isEmpty) return true;
    final masks = fields.keys
        .map((k) => 'updateMask.fieldPaths=${Uri.encodeQueryComponent(k)}')
        .join('&');
    final uri = Uri.parse(
      '${FirebaseProjectConfig.userDocumentUri(uid)}&$masks',
    );
    final body = <String, dynamic>{
      'fields': {
        for (final e in fields.entries) e.key: _encodeFirestoreValue(e.value),
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
        'FirestoreUserDocumentRepository.patchDynamicFields: ${resp.statusCode} ${resp.body}',
      );
      return false;
    }
    return true;
  }
}
