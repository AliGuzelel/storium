import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_session.dart';
import 'firebase_project_config.dart';

class AuthServiceException implements Exception {
  final String code;
  final String message;

  AuthServiceException(this.code, this.message);
}

class AuthService {
  String get _identityBase =>
      'https://identitytoolkit.googleapis.com/v1/accounts';
  Future<UserProfile> signUp({
    required String name,
    required String gender,
    required String email,
    required DateTime? dateOfBirth,
    required String password,
  }) async {
    final signUpResp = await _postJson(
      Uri.parse('$_identityBase:signUp?key=${FirebaseProjectConfig.apiKey}'),
      {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
      isLoginRequest: false,
    );
    final uid = signUpResp['localId'] as String?;
    final idToken = signUpResp['idToken'] as String?;
    if (uid == null || idToken == null) {
      throw AuthServiceException(
        'user-creation-failed',
        'Could not create user.',
      );
    }

    final profile = UserProfile(
      uid: uid,
      idToken: idToken,
      name: name,
      gender: gender,
      email: email,
      dateOfBirth: dateOfBirth,
    );

    await _saveProfile(profile, idToken: idToken);
    return profile;
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final signInResp = await _postJson(
      Uri.parse(
        '$_identityBase:signInWithPassword?key=${FirebaseProjectConfig.apiKey}',
      ),
      {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
      isLoginRequest: true,
    );
    final uid = signInResp['localId'] as String?;
    final idToken = signInResp['idToken'] as String?;
    if (uid == null || idToken == null) {
      throw AuthServiceException(
        'invalid-credential',
        'Invalid username or password',
      );
    }

    final data = await _readProfile(uid: uid, idToken: idToken);

    if (data == null) {
      final fallbackProfile = UserProfile(
        uid: uid,
        idToken: idToken,
        name: _nameFromEmail(email),
        gender: 'Not set',
        email: email,
      );
      await _saveProfile(fallbackProfile, idToken: idToken);
      return fallbackProfile;
    }

    final profile = UserProfile(
      uid: uid,
      idToken: idToken,
      name: (data['name'] as String?) ?? _nameFromEmail(email),
      gender: (data['gender'] as String?) ?? 'Not set',
      email: (data['email'] as String?) ?? email,
      dateOfBirth: _readDate(data['dateOfBirth']),
      avatarUrl: data['avatarUrl'] as String?,
    );
    final localAvatar = await _readLocalAvatar(uid);
    if ((profile.avatarUrl == null || profile.avatarUrl!.isEmpty) &&
        localAvatar != null &&
        localAvatar.isNotEmpty) {
      return profile.copyWith(avatarUrl: localAvatar);
    }
    return profile;
  }

  Future<void> saveProfile(UserProfile profile, {required String idToken}) async {
    await _cacheLocalAvatar(profile);
    await _saveProfile(profile, idToken: idToken);
  }

  Future<void> _saveProfile(
    UserProfile profile, {
    required String idToken,
  }) async {
    final shouldWriteAvatar = _shouldWriteAvatarToCloud(profile.avatarUrl);
    final uri = _userDocUri(
      profile.uid,
      updateMaskFields: <String>[
        'uid',
        'name',
        'gender',
        'email',
        'dateOfBirth',
        if (shouldWriteAvatar) 'avatarUrl',
      ],
    );
    final body = {
      'fields': {
        'uid': {'stringValue': profile.uid},
        'name': {'stringValue': profile.name},
        'gender': {'stringValue': profile.gender},
        'email': {'stringValue': profile.email},
        'dateOfBirth': {
          'stringValue': profile.dateOfBirth?.toIso8601String() ?? '',
        },
        if (shouldWriteAvatar)
          'avatarUrl': {'stringValue': profile.avatarUrl ?? ''},
      },
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    http.Response resp = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (resp.statusCode == 404) {
      resp = await http.put(
        _userDocUri(profile.uid),
        headers: headers,
        body: jsonEncode(body),
      );
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw AuthServiceException(
        'profile-save-failed',
        'Could not save user profile.',
      );
    }
  }

  Future<Map<String, dynamic>?> _readProfile({
    required String uid,
    required String idToken,
  }) async {
    final uri = _userDocUri(uid);
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $idToken'},
    );
    if (resp.statusCode == 404) return null;
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw AuthServiceException('profile-read-failed', 'Could not load user profile.');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final fields = decoded['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    return {
      'uid': _stringField(fields['uid']),
      'name': _stringField(fields['name']),
      'gender': _stringField(fields['gender']),
      'email': _stringField(fields['email']),
      'dateOfBirth': _stringField(fields['dateOfBirth']),
      'avatarUrl': _stringField(fields['avatarUrl']),
    };
  }

  Future<Map<String, dynamic>> _postJson(
    Uri uri,
    Map<String, dynamic> payload,
    {required bool isLoginRequest}
  ) async {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMap = decoded['error'] as Map<String, dynamic>?;
      final message = (errorMap?['message'] as String?) ?? 'UNKNOWN';
      throw _mapIdentityError(message, isLoginRequest: isLoginRequest);
    }
    return decoded;
  }

  AuthServiceException _mapIdentityError(
    String message, {
    required bool isLoginRequest,
  }) {
    final normalized = message.trim().toUpperCase();

    if (normalized.startsWith('EMAIL_EXISTS')) {
      return AuthServiceException(
        'email-already-in-use',
        'This email is already registered',
      );
    }

    if (normalized.startsWith('INVALID_EMAIL')) {
      return AuthServiceException(
        'invalid-email',
        'Please enter a valid email',
      );
    }

    if (normalized == 'WEAK_PASSWORD' ||
        normalized.startsWith('WEAK_PASSWORD')) {
      return AuthServiceException(
        'weak-password',
        'Password should be at least 6 characters',
      );
    }

    if (normalized == 'OPERATION_NOT_ALLOWED') {
      return AuthServiceException(
        'operation-not-allowed',
        'Email/password sign-in is disabled in Firebase Auth.',
      );
    }

    if (normalized == 'CONFIGURATION_NOT_FOUND') {
      return AuthServiceException(
        'configuration-not-found',
        'Firebase Auth configuration is missing for this project.',
      );
    }

    if (normalized == 'TOO_MANY_ATTEMPTS_TRY_LATER') {
      return AuthServiceException(
        'too-many-attempts',
        'Too many attempts. Please try again later.',
      );
    }

    if (normalized == 'API_KEY_INVALID' || normalized == 'PROJECT_NOT_FOUND') {
      return AuthServiceException(
        'firebase-config-error',
        'Firebase project configuration is invalid.',
      );
    }

    if (!isLoginRequest) {
      if (normalized.startsWith('INVALID_PASSWORD')) {
        return AuthServiceException(
          'weak-password',
          'Password should be at least 6 characters',
        );
      }
    }

    if (isLoginRequest) {
      final invalidCredentialCodes = <String>{
        'INVALID_LOGIN_CREDENTIALS',
        'EMAIL_NOT_FOUND',
        'INVALID_PASSWORD',
        'USER_NOT_FOUND',
        'WRONG_PASSWORD',
        'INVALID_CREDENTIALS',
        'USER_DISABLED',
      };
      if (invalidCredentialCodes.contains(normalized)) {
        return AuthServiceException(
          'invalid-credential',
          'Invalid username or password',
        );
      }

      if (normalized.contains('LOGIN') &&
          (normalized.contains('CREDENTIAL') || normalized.contains('CRED'))) {
        return AuthServiceException(
          'invalid-credential',
          'Invalid username or password',
        );
      }

      return AuthServiceException(
        'invalid-credential',
        'Invalid username or password',
      );
    }

    return AuthServiceException(
      'auth-failed',
      'Authentication failed ($normalized).',
    );
  }

  String? _stringField(Object? field) {
    if (field is Map<String, dynamic>) {
      final value = field['stringValue'] as String?;
      if (value == null || value.isEmpty) return null;
      return value;
    }
    return null;
  }

  DateTime? _readDate(Object? raw) {
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  String _nameFromEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) return 'User';
    return email.substring(0, atIndex);
  }

  bool _shouldWriteAvatarToCloud(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return true;
    return !avatarUrl.startsWith('data:image/');
  }

  Future<void> _cacheLocalAvatar(UserProfile profile) async {
    final avatarUrl = profile.avatarUrl;
    final prefs = await SharedPreferences.getInstance();
    if (avatarUrl == null || avatarUrl.isEmpty) {
      await prefs.remove(_avatarKey(profile.uid));
      return;
    }
    if (!avatarUrl.startsWith('data:image/')) {
      await prefs.remove(_avatarKey(profile.uid));
      return;
    }
    await prefs.setString(_avatarKey(profile.uid), avatarUrl);
  }

  Future<String?> _readLocalAvatar(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final avatar = prefs.getString(_avatarKey(uid));
    if (avatar == null || avatar.isEmpty) return null;
    return avatar;
  }

  String _avatarKey(String uid) => 'avatar_cache_$uid';

  Uri _userDocUri(String uid, {List<String> updateMaskFields = const []}) {
    final base =
        '${FirebaseProjectConfig.firestoreDocumentsBase}/users/$uid?key=${FirebaseProjectConfig.apiKey}';
    if (updateMaskFields.isEmpty) return Uri.parse(base);
    final masks = updateMaskFields
        .map((f) => 'updateMask.fieldPaths=${Uri.encodeQueryComponent(f)}')
        .join('&');
    return Uri.parse('$base&$masks');
  }
}
