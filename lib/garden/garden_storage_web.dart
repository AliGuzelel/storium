


import 'dart:html' as html;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/user_session.dart';
import '../services/firestore_user_document_repository.dart';
import 'garden_models.dart';


class GardenStorage {
  static const _plantIdKey = 'garden_plant_id';
  static const _stageKey = 'garden_stage';
  static const _lastWaterKey = 'garden_last_watered_ms';
  static const _nextWaterKey = 'garden_next_water_ms';
  static const _completedKey = 'garden_completed_types';
  static const _schemaKey = 'garden_plant_schema_int';
  static const _stateJsonKey = 'garden_state_json_v2';
  static const _selectedPageKey = 'garden_selected_plant_page';
  static const _fertilizerCountKey = 'garden_fertilizer_count';
  static const _legacyAlliumId = 'lavender';

  static const int currentSchema = 4;

  static String _slotStageKey(String id) => 'garden_slot_${id}_stage';
  static String _slotLastKey(String id) => 'garden_slot_${id}_last_ms';
  static String _slotNextKey(String id) => 'garden_slot_${id}_next_ms';

  static html.Storage get _storage => html.window.localStorage;

  static Set<String> _parseCompleted(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    return raw
        .split(',')
        .map((e) {
          final id = e.trim();
          return id == _legacyAlliumId ? 'allium' : id;
        })
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  static GardenPlantSlot _readSlot(String id, String scope) {
    String k(String base) => '${base}_$scope';
    final fallbackId = id == 'allium' ? _legacyAlliumId : null;
    final stageRaw =
        _storage[k(_slotStageKey(id))] ??
        (fallbackId == null ? null : _storage[k(_slotStageKey(fallbackId))]);
    final parsed = int.tryParse(stageRaw ?? '');
    final phase = (parsed ?? 0).clamp(0, 3);
    final lastMs = int.tryParse(
      _storage[k(_slotLastKey(id))] ??
          (fallbackId == null ? '' : _storage[k(_slotLastKey(fallbackId))] ?? ''),
    );
    final nextMs = int.tryParse(
      _storage[k(_slotNextKey(id))] ??
          (fallbackId == null ? '' : _storage[k(_slotNextKey(fallbackId))] ?? ''),
    );
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

  static bool _hasLegacyKeys(String scope) {
    String k(String base) => '${base}_$scope';
    return _storage[k(_plantIdKey)] != null ||
        _storage[k(_stageKey)] != null ||
        _storage[k(_lastWaterKey)] != null ||
        _storage[k(_nextWaterKey)] != null;
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

  static Future<GardenPersistedState> load({String? uidScope}) async {
    try {
      final scope = (uidScope == null || uidScope.isEmpty) ? 'guest' : uidScope;
      String k(String base) => '${base}_$scope';

      final blob = _storage[k(_stateJsonKey)];
      if (blob != null && blob.isNotEmpty) {
        try {
          return GardenPersistedState.fromJsonString(blob);
        } catch (_) {}
      }

      final schemaRaw = _storage[k(_schemaKey)];
      final schema = int.tryParse(schemaRaw ?? '') ?? 0;
      if (schema < currentSchema) {
        _purgeObsoleteSlots();
        final completed = _parseCompleted(_storage[k(_completedKey)]);
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
        await save(fresh, uidScope: scope);
        return fresh;
      }

      final completed = _parseCompleted(_storage[k(_completedKey)]);
      final hasNew =
          _storage[k(_slotStageKey(GardenPersistedState.allPlantIds.first))] != null;

      if (!hasNew) {
        if (_hasLegacyKeys(scope)) {
          final migrated = _migrateFromLegacy(completed, scope);
          await save(migrated, uidScope: scope);
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
        await save(fresh, uidScope: scope);
        return fresh;
      }

      final slots = <String, GardenPlantSlot>{
        for (final id in GardenPersistedState.allPlantIds) id: _readSlot(id, scope),
      };
      final page = (int.tryParse(_storage[k(_selectedPageKey)] ?? '') ?? 0)
          .clamp(0, GardenPlantOption.choices.length - 1);
      return GardenPersistedState(
        slots: slots,
        completedPlantTypes: completed,
        selectedPlantPageIndex: page,
        fertilizerCount:
            (int.tryParse(_storage[k(_fertilizerCountKey)] ?? '') ?? 0).clamp(0, 999999),
      );
    } catch (e, st) {
      debugPrint('GardenStorage.load (web): $e\n$st');
      return GardenPersistedState(
        slots: {
          for (final id in GardenPersistedState.allPlantIds)
            id: const GardenPlantSlot(),
        },
        selectedPlantPageIndex: 0,
      );
    }
  }

  static GardenPersistedState _migrateFromLegacy(
    Set<String> completed,
    String scope,
  ) {
    String k(String base) => '${base}_$scope';
    final plantId = _storage[k(_plantIdKey)];
    final stageRaw = _storage[k(_stageKey)];
    final parsed = int.tryParse(stageRaw ?? '');
    final phase = (parsed ?? 1).clamp(0, 3);
    final lastMs = int.tryParse(_storage[k(_lastWaterKey)] ?? '');
    final nextMs = int.tryParse(_storage[k(_nextWaterKey)] ?? '');

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

  static Future<void> importFromRemoteJsonString(
    String raw, {
    String? uidScope,
  }) async {
    try {
      final state = GardenPersistedState.fromJsonString(raw);
      await save(state, pushToCloud: false, uidScope: uidScope);
    } catch (e, st) {
      debugPrint('GardenStorage.importFromRemoteJsonString: $e\n$st');
    }
  }

  static Future<void> save(
    GardenPersistedState state, {
    bool pushToCloud = true,
    String? uidScope,
  }) async {
    try {
      final scope = (uidScope == null || uidScope.isEmpty) ? 'guest' : uidScope;
      String k(String base) => '${base}_$scope';

      if (state.completedPlantTypes.isEmpty) {
        _storage.remove(k(_completedKey));
      } else {
        _storage[k(_completedKey)] = state.completedPlantTypes.join(',');
      }

      for (final id in GardenPersistedState.allPlantIds) {
        final s = state.slotFor(id);
        _storage[k(_slotStageKey(id))] = '${s.currentPhase.clamp(0, 3)}';
        if (s.lastWateredAt == null) {
          _storage.remove(k(_slotLastKey(id)));
        } else {
          _storage[k(_slotLastKey(id))] =
              '${s.lastWateredAt!.millisecondsSinceEpoch}';
        }
        if (s.nextWaterAllowedAt == null) {
          _storage.remove(k(_slotNextKey(id)));
        } else {
          _storage[k(_slotNextKey(id))] =
              '${s.nextWaterAllowedAt!.millisecondsSinceEpoch}';
        }
      }
      
      _storage.remove(k(_slotStageKey(_legacyAlliumId)));
      _storage.remove(k(_slotLastKey(_legacyAlliumId)));
      _storage.remove(k(_slotNextKey(_legacyAlliumId)));

      _storage[k(_selectedPageKey)] =
          '${state.selectedPlantPageIndex.clamp(0, GardenPlantOption.choices.length - 1)}';
      _storage[k(_fertilizerCountKey)] = '${state.fertilizerCount.clamp(0, 999999)}';
      _storage[k(_schemaKey)] = '$currentSchema';
      _storage[k(_stateJsonKey)] = state.toJsonString();
      _clearLegacy();

      if (pushToCloud) {
        final u = UserSession.currentUser;
        final cloudUid = uidScope ?? u?.uid;
        if (u != null &&
            cloudUid != null &&
            cloudUid.isNotEmpty &&
            u.uid == cloudUid &&
            u.idToken.isNotEmpty) {
          try {
            await FirestoreUserDocumentRepository.patchStringFields(
              uid: cloudUid,
              idToken: u.idToken,
              stringFields: {'gardenJson': state.toJsonString()},
            );
          } catch (e, st) {
            debugPrint('GardenStorage cloud push: $e\n$st');
          }
        }
      }
    } catch (e, st) {
      debugPrint('GardenStorage.save (web): $e\n$st');
    }
  }

  
  static Duration randomWaterCooldown(math.Random rng) {
    return const Duration(seconds: 5);
  }
}
