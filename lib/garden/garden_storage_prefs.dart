import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_session.dart';
import '../services/firestore_user_document_repository.dart';
import 'garden_models.dart';

/// Loads / saves garden progress via [SharedPreferences] (VM, mobile, desktop).
class GardenStorage {
  static const _plantIdKey = 'garden_plant_id';
  static const _stageKey = 'garden_stage';
  static const _lastWaterKey = 'garden_last_watered_ms';
  static const _nextWaterKey = 'garden_next_water_ms';
  static const _completedKey = 'garden_completed_types';
  static const _schemaKey = 'garden_plant_schema_int';
  static const _selectedPageKey = 'garden_selected_plant_page';

  /// Bump when the persisted plant catalog or slot format changes.
  static const int currentSchema = 4;

  static String _slotStageKey(String id) => 'garden_slot_${id}_stage';
  static String _slotLastKey(String id) => 'garden_slot_${id}_last_ms';
  static String _slotNextKey(String id) => 'garden_slot_${id}_next_ms';

  static Set<String> _parseCompleted(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  static GardenPlantSlot _readSlot(SharedPreferences prefs, String id) {
    final phase = (prefs.getInt(_slotStageKey(id)) ?? 0).clamp(0, 3);
    final lastMs = prefs.getInt(_slotLastKey(id));
    final nextMs = prefs.getInt(_slotNextKey(id));
    return GardenPlantSlot(
      currentPhase: phase,
      lastWateredAt: lastMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastMs),
      nextWaterAllowedAt: nextMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(nextMs),
    );
  }

  static bool _hasLegacyKeys(SharedPreferences prefs) {
    return prefs.containsKey(_plantIdKey) ||
        prefs.containsKey(_stageKey) ||
        prefs.containsKey(_lastWaterKey) ||
        prefs.containsKey(_nextWaterKey);
  }

  static Future<void> _purgeObsoleteSlots(SharedPreferences prefs) async {
    const obsolete = <String>{
      'fern',
      'bloom',
      'vine',
      'sakura',
      'lotus',
      'willow',
      'cedar',
    };
    for (final id in obsolete) {
      await prefs.remove(_slotStageKey(id));
      await prefs.remove(_slotLastKey(id));
      await prefs.remove(_slotNextKey(id));
    }
  }

  static Future<GardenPersistedState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final schema = prefs.getInt(_schemaKey) ?? 0;
    if (schema < currentSchema) {
      await _purgeObsoleteSlots(prefs);
      final completed = _parseCompleted(prefs.getString(_completedKey));
      final filtered = completed
          .where(GardenPersistedState.allPlantIds.contains)
          .toSet();
      final fresh = GardenPersistedState(
        slots: {
          for (final id in GardenPersistedState.allPlantIds)
            id: const GardenPlantSlot(),
        },
        completedPlantTypes: filtered,
        selectedPlantPageIndex: 0,
      );
      await save(fresh);
      return fresh;
    }

    final completed = _parseCompleted(prefs.getString(_completedKey));

    final hasNewSlots =
        prefs.containsKey(_slotStageKey(GardenPersistedState.allPlantIds.first));
    if (!hasNewSlots) {
      if (_hasLegacyKeys(prefs)) {
        final migrated = _migrateFromLegacy(prefs, completed);
        await save(migrated);
        return migrated;
      }
      final fresh = GardenPersistedState(
        slots: {
          for (final id in GardenPersistedState.allPlantIds)
            id: const GardenPlantSlot(),
        },
        completedPlantTypes: completed,
        selectedPlantPageIndex: 0,
      );
      await save(fresh);
      return fresh;
    }

    final slots = <String, GardenPlantSlot>{
      for (final id in GardenPersistedState.allPlantIds) id: _readSlot(prefs, id),
    };
    final page = (prefs.getInt(_selectedPageKey) ?? 0)
        .clamp(0, GardenPlantOption.choices.length - 1);
    return GardenPersistedState(
      slots: slots,
      completedPlantTypes: completed,
      selectedPlantPageIndex: page,
    );
  }

  static GardenPersistedState _migrateFromLegacy(
    SharedPreferences prefs,
    Set<String> completed,
  ) {
    final plantId = prefs.getString(_plantIdKey);
    final phase = (prefs.getInt(_stageKey) ?? 1).clamp(0, 3);
    final lastMs = prefs.getInt(_lastWaterKey);
    final nextMs = prefs.getInt(_nextWaterKey);

    final slots = <String, GardenPlantSlot>{
      for (final id in GardenPersistedState.allPlantIds)
        id: const GardenPlantSlot(),
    };

    if (plantId != null &&
        plantId.isNotEmpty &&
        GardenPersistedState.allPlantIds.contains(plantId)) {
      slots[plantId] = GardenPlantSlot(
        currentPhase: phase,
        lastWateredAt: lastMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(lastMs),
        nextWaterAllowedAt: nextMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(nextMs),
      );
    }

    return GardenPersistedState(
      slots: slots,
      completedPlantTypes: completed,
      selectedPlantPageIndex: 0,
    );
  }

  static Future<void> _clearLegacy(SharedPreferences prefs) async {
    await prefs.remove(_plantIdKey);
    await prefs.remove(_stageKey);
    await prefs.remove(_lastWaterKey);
    await prefs.remove(_nextWaterKey);
  }

  /// Apply remote JSON from Firestore (writes local cache only).
  static Future<void> importFromRemoteJsonString(String raw) async {
    try {
      final state = GardenPersistedState.fromJsonString(raw);
      await save(state, pushToCloud: false);
    } catch (e, st) {
      debugPrint('GardenStorage.importFromRemoteJsonString: $e\n$st');
    }
  }

  static Future<void> save(
    GardenPersistedState state, {
    bool pushToCloud = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (state.completedPlantTypes.isEmpty) {
      await prefs.remove(_completedKey);
    } else {
      await prefs.setString(
        _completedKey,
        state.completedPlantTypes.join(','),
      );
    }

    for (final id in GardenPersistedState.allPlantIds) {
      final s = state.slotFor(id);
      await prefs.setInt(_slotStageKey(id), s.currentPhase.clamp(0, 3));
      if (s.lastWateredAt == null) {
        await prefs.remove(_slotLastKey(id));
      } else {
        await prefs.setInt(
          _slotLastKey(id),
          s.lastWateredAt!.millisecondsSinceEpoch,
        );
      }
      if (s.nextWaterAllowedAt == null) {
        await prefs.remove(_slotNextKey(id));
      } else {
        await prefs.setInt(
          _slotNextKey(id),
          s.nextWaterAllowedAt!.millisecondsSinceEpoch,
        );
      }
    }

    await prefs.setInt(
      _selectedPageKey,
      state.selectedPlantPageIndex
          .clamp(0, GardenPlantOption.choices.length - 1),
    );
    await prefs.setInt(_schemaKey, currentSchema);
    await _clearLegacy(prefs);

    if (pushToCloud) {
      final u = UserSession.currentUser;
      if (u != null && u.uid.isNotEmpty && u.idToken.isNotEmpty) {
        try {
          await FirestoreUserDocumentRepository.patchStringFields(
            uid: u.uid,
            idToken: u.idToken,
            stringFields: {'gardenJson': state.toJsonString()},
          );
        } catch (e, st) {
          debugPrint('GardenStorage cloud push: $e\n$st');
        }
      }
    }
  }

  /// Temporary: fixed short cooldown for testing (restore 8–24h random later).
  static Duration randomWaterCooldown(math.Random rng) {
    return const Duration(seconds: 5);
  }
}
