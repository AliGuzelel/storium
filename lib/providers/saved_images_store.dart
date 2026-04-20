import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_image_entry.dart';

/// Saved My Space items (local only).
class SavedImagesStore extends ChangeNotifier {
  SavedImagesStore();

  static const String _prefsKeyV2 = 'my_space_saved_images_v2';
  static const String _prefsKeyLegacy = 'my_space_saved_images';

  final List<SavedImageEntry> _entries = <SavedImageEntry>[];

  List<SavedImageEntry> get entries => List<SavedImageEntry>.unmodifiable(_entries);

  /// Paths only (convenience).
  List<String> get savedImages =>
      _entries.map((e) => e.path).toList(growable: false);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawV2 = prefs.getString(_prefsKeyV2);
    _entries.clear();

    if (rawV2 != null && rawV2.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawV2) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map) {
            _entries.add(
              SavedImageEntry.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      } catch (_) {
        _entries.clear();
      }
    }

    if (_entries.isEmpty) {
      final legacy = prefs.getStringList(_prefsKeyLegacy);
      if (legacy != null && legacy.isNotEmpty) {
        for (final p in legacy) {
          final path = p.trim();
          if (path.isNotEmpty) {
            _entries.add(SavedImageEntry(path: path));
          }
        }
        await _persist();
        await prefs.remove(_prefsKeyLegacy);
      }
    }

    notifyListeners();
  }

  /// Add path with optional caption.
  /// Returns `true` if a new entry was saved, `false` if path was empty or already saved.
  Future<bool> add(String imagePath, {String? caption}) async {
    final path = imagePath.trim();
    if (path.isEmpty) return false;
    if (_entries.any((e) => e.path == path)) return false;
    final cap = caption?.trim();
    _entries.add(
      SavedImageEntry(
        path: path,
        caption: (cap != null && cap.isNotEmpty) ? cap : null,
      ),
    );
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> remove(String imagePath) async {
    final path = imagePath.trim();
    if (path.isEmpty) return;
    _entries.removeWhere((e) => e.path == path);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKeyV2, raw);
  }
}
