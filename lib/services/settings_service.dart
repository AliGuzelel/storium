import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';
import '../models/user_session.dart';
import 'firestore_user_document_repository.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  static const String _textScaleKey = 'settings_text_scale';
  static const String _languageKey = 'settings_language';
  static const String _themeColorKey = 'settings_theme_color';
  static const String _isDarkModeKey = 'settings_is_dark_mode';
  static const String _musicVolumeKey = 'settings_music_volume';
  static const String _soundVolumeKey = 'settings_sound_volume';

  Future<SettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final hasStructuredKeys =
        prefs.containsKey(_textScaleKey) ||
        prefs.containsKey(_languageKey) ||
        prefs.containsKey(_themeColorKey) ||
        prefs.containsKey(_isDarkModeKey) ||
        prefs.containsKey(_musicVolumeKey) ||
        prefs.containsKey(_soundVolumeKey);

    if (hasStructuredKeys) {
      return SettingsModel(
        textScale: prefs.getDouble(_textScaleKey) ?? 1.0,
        language: prefs.getString(_languageKey) ?? 'en',
        themeColor: prefs.getString(_themeColorKey) ?? 'purple',
        isDarkMode: prefs.getBool(_isDarkModeKey) ?? false,
        musicVolume: prefs.getDouble(_musicVolumeKey) ?? 50,
        soundVolume: prefs.getDouble(_soundVolumeKey) ?? 50,
      );
    }

    
    final raw = prefs.getString(_settingsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final legacy = SettingsModel.fromJson(map);
        await _saveStructured(prefs, legacy);
        return legacy;
      } catch (_) {
        
      }
    }

    return const SettingsModel();
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await _saveStructured(prefs, settings);
    
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    await _pushToFirestore(settings);
  }

  
  Future<void> importFromRemoteString(String jsonStr) async {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final settings = SettingsModel.fromJson(map);
    final prefs = await SharedPreferences.getInstance();
    await _saveStructured(prefs, settings);
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<void> _pushToFirestore(SettingsModel settings) async {
    final u = UserSession.currentUser;
    if (u == null || u.uid.isEmpty || u.idToken.isEmpty) return;
    try {
      await FirestoreUserDocumentRepository.patchStringFields(
        uid: u.uid,
        idToken: u.idToken,
        stringFields: {'settingsJson': jsonEncode(settings.toJson())},
      );
    } catch (e, st) {
      debugPrint('SettingsService._pushToFirestore: $e\n$st');
    }
  }

  Future<void> _saveStructured(
    SharedPreferences prefs,
    SettingsModel settings,
  ) async {
    await prefs.setDouble(_textScaleKey, settings.textScale);
    await prefs.setString(_languageKey, settings.language);
    await prefs.setString(_themeColorKey, settings.themeColor);
    await prefs.setBool(_isDarkModeKey, settings.isDarkMode);
    await prefs.setDouble(_musicVolumeKey, settings.musicVolume);
    await prefs.setDouble(_soundVolumeKey, settings.soundVolume);
  }
}
