// Web-only implementation; not used on VM/tests.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/user_session.dart';
import '../services/firestore_user_document_repository.dart';
import 'garden_models.dart';

/// Loads / saves garden progress via [window.localStorage] (browser only).
class GardenStorage {
  static const _plantIdKey = 'garden_plant_id';
  static const _stageKey = 'garden_stage';
  static const _lastWaterKey = 'garden_last_watered_ms';
  static const _nextWaterKey = 'garden_next_water_ms';
  static const _completedKey = 'garden_completed_types';
  static const _schemaKey = 'garden_plant_schema_int';
  static const _selectedPageKey = 'garden_selected_plant_page';
  static const _fertilizerCountKey = 'garden_fertilizer_count';

  static const int currentSchema = 4;

  static String _slotStageKey(String id) => 'garden_slot_${id}_stage';
  static String _slotLastKey(String id) => 'garden_slot_${id}_last_ms';
  static String _slotNextKey(String id) => 'garden_slot_${id}_next_ms';

  static html.Storage get _storage => html.window.localStorage;

  static Set<String> _parseCompleted(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  static GardenPlantSlot _readSlot(String id) {
    final stageRaw = _storage[_slotStageKey(id)];
    final parsed = int.tryParse(stageRaw ?? '');
    final phase = (parsed ?? 0).clamp(0, 3);
    final lastMs = int.tryParse(_storage[_slotLastKey(id)] ?? '');
    final nextMs = int.tryParse(_storage[_slotNextKey(id)] ?? '');
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

  static bool _hasLegacyKeys() {
    return _storage[_plantIdKey] != null ||
        _storage[_stageKey] != null ||
        _storage[_lastWaterKey] != null ||
        _storage[_nextWaterKey] != null;
  }

  static void _purgeObsoleteSlots() {
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
      _storage.remove(_slotStageKey(id));
      _storage.remove(_slotLastKey(id));
      _storage.remove(_slotNextKey(id));
    }
  }

  static Future<GardenPersistedState> load() async {
    final schemaRaw = _storage[_schemaKey];
    final schema = int.tryParse(schemaRaw ?? '') ?? 0;
    if (schema < currentSchema) {
      _purgeObsoleteSlots();
      final completed = _parseCompleted(_storage[_completedKey]);
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

    final completed = _parseCompleted(_storage[_completedKey]);
    final hasNew =
        _storage[_slotStageKey(GardenPersistedState.allPlantIds.first)] != null;

    if (!hasNew) {
      if (_hasLegacyKeys()) {
        final migrated = _migrateFromLegacy(completed);
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
      for (final id in GardenPersistedState.allPlantIds) id: _readSlot(id),
    };
    final page = (int.tryParse(_storage[_selectedPageKey] ?? '') ?? 0)
        .clamp(0, GardenPlantOption.choices.length - 1);
    return GardenPersistedState(
      slots: slots,
      completedPlantTypes: completed,
      selectedPlantPageIndex: page,
      fertilizerCount:
          (int.tryParse(_storage[_fertilizerCountKey] ?? '') ?? 0).clamp(0, 999999),
    );
  }

  static GardenPersistedState _migrateFromLegacy(Set<String> completed) {
    final plantId = _storage[_plantIdKey];
    final stageRaw = _storage[_stageKey];
    final parsed = int.tryParse(stageRaw ?? '');
    final phase = (parsed ?? 1).clamp(0, 3);
    final lastMs = int.tryParse(_storage[_lastWaterKey] ?? '');
    final nextMs = int.tryParse(_storage[_nextWaterKey] ?? '');

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

  static void _clearLegacy() {
    _storage.remove(_plantIdKey);
    _storage.remove(_stageKey);
    _storage.remove(_lastWaterKey);
    _storage.remove(_nextWaterKey);
  }

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
    if (state.completedPlantTypes.isEmpty) {
      _storage.remove(_completedKey);
    } else {
      _storage[_completedKey] = state.completedPlantTypes.join(',');
    }

    for (final id in GardenPersistedState.allPlantIds) {
      final s = state.slotFor(id);
      _storage[_slotStageKey(id)] = '${s.currentPhase.clamp(0, 3)}';
      if (s.lastWateredAt == null) {
        _storage.remove(_slotLastKey(id));
      } else {
        _storage[_slotLastKey(id)] =
            '${s.lastWateredAt!.millisecondsSinceEpoch}';
      }
      if (s.nextWaterAllowedAt == null) {
        _storage.remove(_slotNextKey(id));
      } else {
        _storage[_slotNextKey(id)] =
            '${s.nextWaterAllowedAt!.millisecondsSinceEpoch}';
      }
    }

    _storage[_selectedPageKey] =
        '${state.selectedPlantPageIndex.clamp(0, GardenPlantOption.choices.length - 1)}';
    _storage[_fertilizerCountKey] = '${state.fertilizerCount.clamp(0, 999999)}';
    _storage[_schemaKey] = '$currentSchema';
    _clearLegacy();

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
