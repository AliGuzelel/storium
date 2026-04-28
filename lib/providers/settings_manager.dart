import 'package:flutter/material.dart';

import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../theme/app_themes.dart';

class SettingsManager extends ChangeNotifier {
  final SettingsService _service;
  SettingsModel _settings = const SettingsModel();

  SettingsManager({SettingsService? service})
    : _service = service ?? SettingsService();

  SettingsModel get settings => _settings;
  double get textScale => _settings.textScale;
  String get language => _settings.language;
  String get themeColor => _settings.themeColor;
  bool get isDarkMode => _settings.isDarkMode;
  double get musicVolume => _settings.musicVolume;
  double get soundVolume => _settings.soundVolume;

  Future<void> initialize() async {
    final loaded = await _service.loadSettings();
    final normalizedTheme = AppThemes.normalizeThemeColor(loaded.themeColor);
    _settings = loaded.copyWith(themeColor: normalizedTheme);
    if (normalizedTheme != loaded.themeColor) {
      await _service.saveSettings(_settings);
    }
    notifyListeners();
  }

  
  Future<void> reloadFromDisk() async {
    final loaded = await _service.loadSettings();
    final normalizedTheme = AppThemes.normalizeThemeColor(loaded.themeColor);
    _settings = loaded.copyWith(themeColor: normalizedTheme);
    if (normalizedTheme != loaded.themeColor) {
      await _service.saveSettings(_settings);
    }
    notifyListeners();
  }

  Future<void> updateTextScale(double value) async {
    _settings = _settings.copyWith(textScale: value);
    await _persistAndNotify();
  }

  Future<void> updateLanguage(String value) async {
    _settings = _settings.copyWith(language: value);
    await _persistAndNotify();
  }

  Future<void> updateThemeColor(String value) async {
    _settings = _settings.copyWith(
      themeColor: AppThemes.normalizeThemeColor(value),
    );
    await _persistAndNotify();
  }

  Future<void> toggleDarkMode(bool value) async {
    _settings = _settings.copyWith(isDarkMode: value);
    await _persistAndNotify();
  }

  Future<void> updateMusicVolume(double value) async {
    _settings = _settings.copyWith(musicVolume: value);
    await _persistAndNotify();
  }

  Future<void> updateSoundVolume(double value) async {
    _settings = _settings.copyWith(soundVolume: value);
    await _persistAndNotify();
  }

  Future<void> _persistAndNotify() async {
    await _service.saveSettings(_settings);
    notifyListeners();
  }
}
