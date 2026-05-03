import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static String _scopeSuffix([String? uidOverride]) {
    final uid = uidOverride ?? UserSession.currentUser?.uid;
    if (uid == null || uid.isEmpty) return 'guest';
    return uid;
  }

  static String _k(String base) => '${base}_${_scopeSuffix()}';
  static String _kForSuffix(String base, String suffix) => '${base}_$suffix';

  static String _slotStageKey(String id) => _k('garden_slot_${id}_stage');
  static String _slotLastKey(String id) => _k('garden_slot_${id}_last_ms');
  static String _slotNextKey(String id) => _k('garden_slot_${id}_next_ms');
  static String _slotStageKeyWithSuffix(String id, String suffix) =>
      _kForSuffix('garden_slot_${id}_stage', suffix);
  static String _slotLastKeyWithSuffix(String id, String suffix) =>
      _kForSuffix('garden_slot_${id}_last_ms', suffix);
  static String _slotNextKeyWithSuffix(String id, String suffix) =>
      _kForSuffix('garden_slot_${id}_next_ms', suffix);
  static String _slotStageKeyForSuffix(String id, String suffix) =>
      _kForSuffix('garden_slot_${id}_stage', suffix);
  static String _slotLastKeyForSuffix(String id, String suffix) =>
      _kForSuffix('garden_slot_${id}_last_ms', suffix);
  static String _slotNextKeyForSuffix(String id, String suffix) =>
      _kForSuffix('garden_slot_${id}_next_ms', suffix);

  static Future<void> _migrateLegacyScopesIfNeeded(
    SharedPreferences prefs,
    String scopeSuffix,
  ) async {
    final user = UserSession.currentUser;
    if (user == null || user.uid.isEmpty) return;
    if (prefs.containsKey(_kForSuffix(_schemaKey, scopeSuffix))) return;

    final hasUnscoped = prefs.containsKey(_schemaKey);
    final hasGuestScoped = prefs.containsKey(_kForSuffix(_schemaKey, 'guest'));
    if (!hasUnscoped && !hasGuestScoped) return;

    Future<void> copyStringIfAbsent(String scopedKey, List<String> candidates) async {
      if (prefs.containsKey(scopedKey)) return;
      for (final c in candidates) {
        final v = prefs.getString(c);
        if (v != null) {
          await prefs.setString(scopedKey, v);
          return;
        }
      }
    }

    Future<void> copyIntIfAbsent(String scopedKey, List<String> candidates) async {
      if (prefs.containsKey(scopedKey)) return;
      for (final c in candidates) {
        final v = prefs.getInt(c);
        if (v != null) {
          await prefs.setInt(scopedKey, v);
          return;
        }
      }
    }

    await copyStringIfAbsent(_kForSuffix(_completedKey, scopeSuffix), [
      _completedKey,
      _kForSuffix(_completedKey, 'guest'),
    ]);
    await copyIntIfAbsent(_kForSuffix(_schemaKey, scopeSuffix), [
      _schemaKey,
      _kForSuffix(_schemaKey, 'guest'),
    ]);
    await copyIntIfAbsent(_kForSuffix(_selectedPageKey, scopeSuffix), [
      _selectedPageKey,
      _kForSuffix(_selectedPageKey, 'guest'),
    ]);
    await copyIntIfAbsent(_kForSuffix(_fertilizerCountKey, scopeSuffix), [
      _fertilizerCountKey,
      _kForSuffix(_fertilizerCountKey, 'guest'),
    ]);
    await copyStringIfAbsent(_kForSuffix(_plantIdKey, scopeSuffix), [
      _plantIdKey,
      _kForSuffix(_plantIdKey, 'guest'),
    ]);
    await copyIntIfAbsent(_kForSuffix(_stageKey, scopeSuffix), [
      _stageKey,
      _kForSuffix(_stageKey, 'guest'),
    ]);
    await copyIntIfAbsent(_kForSuffix(_lastWaterKey, scopeSuffix), [
      _lastWaterKey,
      _kForSuffix(_lastWaterKey, 'guest'),
    ]);
    await copyIntIfAbsent(_kForSuffix(_nextWaterKey, scopeSuffix), [
      _nextWaterKey,
      _kForSuffix(_nextWaterKey, 'guest'),
    ]);

    for (final id in GardenPersistedState.allPlantIds) {
      await copyIntIfAbsent(_slotStageKeyWithSuffix(id, scopeSuffix), [
        'garden_slot_${id}_stage',
        _slotStageKeyForSuffix(id, 'guest'),
      ]);
      await copyIntIfAbsent(_slotLastKeyWithSuffix(id, scopeSuffix), [
        'garden_slot_${id}_last_ms',
        _slotLastKeyForSuffix(id, 'guest'),
      ]);
      await copyIntIfAbsent(_slotNextKeyWithSuffix(id, scopeSuffix), [
        'garden_slot_${id}_next_ms',
        _slotNextKeyForSuffix(id, 'guest'),
      ]);
    }
  }

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

  static GardenPlantSlot _readSlot(
    SharedPreferences prefs,
    String id,
    String scopeSuffix,
  ) {
    final fallbackId = id == 'allium' ? _legacyAlliumId : null;
    final phase = (prefs.getInt(_slotStageKeyWithSuffix(id, scopeSuffix)) ??
            (fallbackId == null
                ? null
                : prefs.getInt(_slotStageKeyWithSuffix(fallbackId, scopeSuffix))) ??
            0)
        .clamp(0, 3);
    final lastMs =
        prefs.getInt(_slotLastKeyWithSuffix(id, scopeSuffix)) ??
        (fallbackId == null
            ? null
            : prefs.getInt(_slotLastKeyWithSuffix(fallbackId, scopeSuffix)));
    final nextMs =
        prefs.getInt(_slotNextKeyWithSuffix(id, scopeSuffix)) ??
        (fallbackId == null
            ? null
            : prefs.getInt(_slotNextKeyWithSuffix(fallbackId, scopeSuffix)));
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

  static bool _hasLegacyKeys(SharedPreferences prefs, String scopeSuffix) {
    return prefs.containsKey(_kForSuffix(_plantIdKey, scopeSuffix)) ||
        prefs.containsKey(_kForSuffix(_stageKey, scopeSuffix)) ||
        prefs.containsKey(_kForSuffix(_lastWaterKey, scopeSuffix)) ||
        prefs.containsKey(_kForSuffix(_nextWaterKey, scopeSuffix));
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

  static Future<GardenPersistedState> load({String? uidScope}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scopeSuffix = _scopeSuffix(uidScope);
      await _migrateLegacyScopesIfNeeded(prefs, scopeSuffix);

      final rawBlob = prefs.getString(_kForSuffix(_stateJsonKey, scopeSuffix));
      if (rawBlob != null && rawBlob.isNotEmpty) {
        try {
          return GardenPersistedState.fromJsonString(rawBlob);
        } catch (_) {
          
        }
      }

      final schema = prefs.getInt(_kForSuffix(_schemaKey, scopeSuffix)) ?? 0;
      if (schema < currentSchema) {
        await _purgeObsoleteSlots(prefs);
        final completed = _parseCompleted(
          prefs.getString(_kForSuffix(_completedKey, scopeSuffix)),
        );
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
        
        await save(fresh, pushToCloud: false, uidScope: scopeSuffix);
        return fresh;
      }

      final completed = _parseCompleted(
        prefs.getString(_kForSuffix(_completedKey, scopeSuffix)),
      );

      final hasNewSlots = prefs.containsKey(
        _slotStageKeyWithSuffix(
          GardenPersistedState.allPlantIds.first,
          scopeSuffix,
        ),
      );
      if (!hasNewSlots) {
        if (_hasLegacyKeys(prefs, scopeSuffix)) {
          final migrated = _migrateFromLegacy(prefs, completed, scopeSuffix);
          
          await save(migrated, pushToCloud: false, uidScope: scopeSuffix);
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
        
        await save(fresh, pushToCloud: false, uidScope: scopeSuffix);
        return fresh;
      }

      final slots = <String, GardenPlantSlot>{
        for (final id in GardenPersistedState.allPlantIds)
          id: _readSlot(prefs, id, scopeSuffix),
      };
      final page = (prefs.getInt(_kForSuffix(_selectedPageKey, scopeSuffix)) ?? 0)
          .clamp(0, GardenPlantOption.choices.length - 1);
      return GardenPersistedState(
        slots: slots,
        completedPlantTypes: completed,
        selectedPlantPageIndex: page,
        fertilizerCount: (prefs.getInt(_kForSuffix(_fertilizerCountKey, scopeSuffix)) ?? 0)
            .clamp(0, 999999),
      );
    } catch (e, st) {
      debugPrint('GardenStorage.load (prefs): $e\n$st');
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
    SharedPreferences prefs,
    Set<String> completed,
    String scopeSuffix,
  ) {
    final plantId = prefs.getString(_kForSuffix(_plantIdKey, scopeSuffix));
    final phase = (prefs.getInt(_kForSuffix(_stageKey, scopeSuffix)) ?? 1).clamp(0, 3);
    final lastMs = prefs.getInt(_kForSuffix(_lastWaterKey, scopeSuffix));
    final nextMs = prefs.getInt(_kForSuffix(_nextWaterKey, scopeSuffix));

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

  static Future<void> _clearLegacy(
    SharedPreferences prefs,
    String scopeSuffix,
  ) async {
    await prefs.remove(_kForSuffix(_plantIdKey, scopeSuffix));
    await prefs.remove(_kForSuffix(_stageKey, scopeSuffix));
    await prefs.remove(_kForSuffix(_lastWaterKey, scopeSuffix));
    await prefs.remove(_kForSuffix(_nextWaterKey, scopeSuffix));
  }

  
  static Future<void> importFromRemoteJsonString(
    String raw, {
    String? uidScope,
  }) async {
    try {
      final remote = GardenPersistedState.fromJsonString(raw);
      final local = await load(uidScope: uidScope);
      final merged = _mergePreferHigherProgress(local, remote);
      await save(merged, pushToCloud: false, uidScope: uidScope);
    } catch (e, st) {
      debugPrint('GardenStorage.importFromRemoteJsonString: $e\n$st');
    }
  }

  static GardenPersistedState _mergePreferHigherProgress(
    GardenPersistedState local,
    GardenPersistedState remote,
  ) {
    final slots = <String, GardenPlantSlot>{};
    for (final id in GardenPersistedState.allPlantIds) {
      final l = local.slotFor(id);
      final r = remote.slotFor(id);
      if (l.currentPhase > r.currentPhase) {
        slots[id] = l;
        continue;
      }
      if (r.currentPhase > l.currentPhase) {
        slots[id] = r;
        continue;
      }
      
      final lTime = l.lastWateredAt;
      final rTime = r.lastWateredAt;
      if (rTime != null && (lTime == null || rTime.isAfter(lTime))) {
        slots[id] = r;
      } else {
        slots[id] = l;
      }
    }
    final completed = {
      ...local.completedPlantTypes,
      ...remote.completedPlantTypes,
    };
    return GardenPersistedState(
      slots: slots,
      completedPlantTypes: completed,
      selectedPlantPageIndex: local.selectedPlantPageIndex,
      fertilizerCount: local.fertilizerCount > remote.fertilizerCount
          ? local.fertilizerCount
          : remote.fertilizerCount,
    );
  }

  static Future<void> save(
    GardenPersistedState state, {
    bool pushToCloud = true,
    String? uidScope,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scopeSuffix = _scopeSuffix(uidScope);

      if (state.completedPlantTypes.isEmpty) {
        await prefs.remove(_kForSuffix(_completedKey, scopeSuffix));
      } else {
        await prefs.setString(
          _kForSuffix(_completedKey, scopeSuffix),
          state.completedPlantTypes.join(','),
        );
      }

      for (final id in GardenPersistedState.allPlantIds) {
        final s = state.slotFor(id);
        await prefs.setInt(
          _slotStageKeyWithSuffix(id, scopeSuffix),
          s.currentPhase.clamp(0, 3),
        );
        if (s.lastWateredAt == null) {
          await prefs.remove(_slotLastKeyWithSuffix(id, scopeSuffix));
        } else {
          await prefs.setInt(
            _slotLastKeyWithSuffix(id, scopeSuffix),
            s.lastWateredAt!.millisecondsSinceEpoch,
          );
        }
        if (s.nextWaterAllowedAt == null) {
          await prefs.remove(_slotNextKeyWithSuffix(id, scopeSuffix));
        } else {
          await prefs.setInt(
            _slotNextKeyWithSuffix(id, scopeSuffix),
            s.nextWaterAllowedAt!.millisecondsSinceEpoch,
          );
        }
      }
      
      await prefs.remove(_slotStageKeyWithSuffix(_legacyAlliumId, scopeSuffix));
      await prefs.remove(_slotLastKeyWithSuffix(_legacyAlliumId, scopeSuffix));
      await prefs.remove(_slotNextKeyWithSuffix(_legacyAlliumId, scopeSuffix));

      await prefs.setInt(
        _kForSuffix(_selectedPageKey, scopeSuffix),
        state.selectedPlantPageIndex
            .clamp(0, GardenPlantOption.choices.length - 1),
      );
      await prefs.setInt(
        _kForSuffix(_fertilizerCountKey, scopeSuffix),
        state.fertilizerCount.clamp(0, 999999),
      );
      await prefs.setInt(_kForSuffix(_schemaKey, scopeSuffix), currentSchema);
      await prefs.setString(
        _kForSuffix(_stateJsonKey, scopeSuffix),
        state.toJsonString(),
      );
      await _clearLegacy(prefs, scopeSuffix);

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
      debugPrint('GardenStorage.save (prefs): $e\n$st');
    }
  }

  
  static Duration randomWaterCooldown(math.Random rng) {
    final hours = 4 + rng.nextInt(7);
    return Duration(hours: hours);
  }
}
