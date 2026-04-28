import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class _AvatarUrlUnset {
  const _AvatarUrlUnset();
}

const Object _kAvatarUrlUnset = _AvatarUrlUnset();

class UserProfile {
  final String uid;
  final String idToken;
  final String name;
  final String gender;
  final String email;
  final DateTime? dateOfBirth;
  final String? avatarUrl;

  const UserProfile({
    required this.uid,
    required this.idToken,
    required this.name,
    required this.gender,
    required this.email,
    this.dateOfBirth,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? uid,
    String? idToken,
    String? name,
    String? gender,
    String? email,
    DateTime? dateOfBirth,
    Object? avatarUrl = _kAvatarUrlUnset,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      idToken: idToken ?? this.idToken,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: identical(avatarUrl, _kAvatarUrlUnset)
          ? this.avatarUrl
          : avatarUrl as String?,
    );
  }

  
  
  Map<String, dynamic> toJson() {
    final a = avatarUrl;
    final storableAvatar =
        (a != null && a.startsWith('data:image/')) ? null : a;
    return {
      'uid': uid,
      'idToken': idToken,
      'name': name,
      'gender': gender,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'avatarUrl': storableAvatar,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawDob = json['dateOfBirth'] as String?;
    return UserProfile(
      uid: (json['uid'] as String?) ?? '',
      idToken: (json['idToken'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'User',
      gender: (json['gender'] as String?) ?? 'Not set',
      email: (json['email'] as String?) ?? '',
      dateOfBirth: rawDob == null ? null : DateTime.tryParse(rawDob),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class UserSession {
  static const _userKey = 'current_user';
  static UserProfile? currentUser;

  static String _avatarCacheKey(String uid) => 'avatar_cache_$uid';

  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_userKey);
    if (encoded == null || encoded.isEmpty) {
      currentUser = null;
      return;
    }

    final decoded = jsonDecode(encoded) as Map<String, dynamic>;
    var user = UserProfile.fromJson(decoded);
    final cached = prefs.getString(_avatarCacheKey(user.uid));
    if (cached != null &&
        cached.isNotEmpty &&
        (user.avatarUrl == null || user.avatarUrl!.isEmpty)) {
      user = user.copyWith(avatarUrl: cached);
    }
    currentUser = user;
  }

  static Future<void> saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = currentUser;
    if (user == null) {
      await prefs.remove(_userKey);
      return;
    }
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUser = null;
    await prefs.remove(_userKey);
  }
}
