import 'dart:convert';


class GardenPlantSlot {
  const GardenPlantSlot({
    this.currentPhase = 0,
    this.lastWateredAt,
    this.nextWaterAllowedAt,
  });

  final int currentPhase;
  final DateTime? lastWateredAt;
  final DateTime? nextWaterAllowedAt;

  bool get isMature => currentPhase >= 3;

  Map<String, dynamic> toJson() => {
        'currentPhase': currentPhase,
        'lastWateredAt': lastWateredAt?.toIso8601String(),
        'nextWaterAllowedAt': nextWaterAllowedAt?.toIso8601String(),
      };

  factory GardenPlantSlot.fromJson(Map<String, dynamic> json) {
    final last = json['lastWateredAt'] as String?;
    final next = json['nextWaterAllowedAt'] as String?;
    return GardenPlantSlot(
      currentPhase: (json['currentPhase'] as num?)?.toInt() ?? 0,
      lastWateredAt: last == null || last.isEmpty ? null : DateTime.tryParse(last),
      nextWaterAllowedAt:
          next == null || next.isEmpty ? null : DateTime.tryParse(next),
    );
  }

  GardenPlantSlot copyWith({
    int? currentPhase,
    DateTime? lastWateredAt,
    DateTime? nextWaterAllowedAt,
    bool clearWaterSchedule = false,
  }) {
    return GardenPlantSlot(
      currentPhase: currentPhase ?? this.currentPhase,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      nextWaterAllowedAt: clearWaterSchedule
          ? null
          : (nextWaterAllowedAt ?? this.nextWaterAllowedAt),
    );
  }
}

class GardenPersistedState {
  const GardenPersistedState({
    this.slots = const {},
    this.completedPlantTypes = const {},
    this.selectedPlantPageIndex = 0,
    this.fertilizerCount = 0,
  });

  final Map<String, GardenPlantSlot> slots;
  final Set<String> completedPlantTypes;
  
  final int selectedPlantPageIndex;
  final int fertilizerCount;

  static List<String> get allPlantIds =>
      GardenPlantOption.choices.map((e) => e.id).toList();
  static const Map<String, String> _legacyPlantIdMap = {'lavender': 'allium'};

  static String _normalizePlantId(String id) => _legacyPlantIdMap[id] ?? id;
  static Iterable<String> _legacyAliasesFor(String id) sync* {
    for (final entry in _legacyPlantIdMap.entries) {
      if (entry.value == id) yield entry.key;
    }
  }
  static Map<String, dynamic> _slotJsonForPlantId(
    Map<String, dynamic> rawSlots,
    String id,
  ) {
    final direct = rawSlots[id];
    if (direct is Map) return Map<String, dynamic>.from(direct);
    for (final legacy in _legacyAliasesFor(id)) {
      final legacySlot = rawSlots[legacy];
      if (legacySlot is Map) return Map<String, dynamic>.from(legacySlot);
    }
    return const <String, dynamic>{};
  }

  static int _clampPageIndex(int i) {
    final n = GardenPlantOption.choices.length;
    if (n <= 0) return 0;
    return i.clamp(0, n - 1);
  }

  GardenPlantSlot slotFor(String plantId) =>
      slots[plantId] ?? const GardenPlantSlot();

  GardenPersistedState copyWithSlot(String plantId, GardenPlantSlot slot) {
    final next = Map<String, GardenPlantSlot>.from(slots);
    next[plantId] = slot;
    return GardenPersistedState(
      slots: next,
      completedPlantTypes: completedPlantTypes,
      selectedPlantPageIndex: selectedPlantPageIndex,
      fertilizerCount: fertilizerCount,
    );
  }

  GardenPersistedState copyWith({
    Map<String, GardenPlantSlot>? slots,
    Set<String>? completedPlantTypes,
    int? selectedPlantPageIndex,
    int? fertilizerCount,
  }) {
    return GardenPersistedState(
      slots: slots ?? this.slots,
      completedPlantTypes: completedPlantTypes ?? this.completedPlantTypes,
      selectedPlantPageIndex:
          selectedPlantPageIndex ?? this.selectedPlantPageIndex,
      fertilizerCount: fertilizerCount ?? this.fertilizerCount,
    );
  }

  Map<String, dynamic> toJson() {
    final slotJson = <String, dynamic>{
      for (final id in allPlantIds) id: slotFor(id).toJson(),
    };
    return {
      'schema': 5,
      'slots': slotJson,
      'completedPlantTypes': completedPlantTypes.toList()..sort(),
      'selectedPlantPageIndex': _clampPageIndex(selectedPlantPageIndex),
      'fertilizerCount': fertilizerCount,
      'plantCatalog': [
        for (final o in GardenPlantOption.choices)
          {
            'id': o.id,
            'name': o.name,
            'description': o.description,
            'imagePath': o.imagePath,
            'images': o.images,
          },
      ],
    };
  }

  factory GardenPersistedState.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'] as Map<String, dynamic>? ?? {};
    final slots = <String, GardenPlantSlot>{
      for (final id in allPlantIds)
        id: GardenPlantSlot.fromJson(
          _slotJsonForPlantId(rawSlots, id),
        ),
    };
    final rawDone = json['completedPlantTypes'] as List<dynamic>? ?? const [];
    final completed = rawDone
        .map((e) => _normalizePlantId(e.toString()))
        .toSet()
      ..removeWhere((id) => !allPlantIds.contains(id));
    final page = (json['selectedPlantPageIndex'] as num?)?.toInt() ?? 0;
    final fertilizer = (json['fertilizerCount'] as num?)?.toInt() ?? 0;
    return GardenPersistedState(
      slots: slots,
      completedPlantTypes: completed,
      selectedPlantPageIndex: _clampPageIndex(page),
      fertilizerCount: fertilizer < 0 ? 0 : fertilizer,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory GardenPersistedState.fromJsonString(String raw) {
    return GardenPersistedState.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
}

class GardenPlantOption {
  const GardenPlantOption({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    this.plantImageHeight = 200,
    this.plantImageWidthFactor = 0.88,
    this.bottomOffset = 0,
    this.plantPhaseScaleFactor = 1.0,
  });

  final String id;
  final String name;
  final String description;
  
  final Map<int, String> images;
  
  final double plantPhaseScaleFactor;
  
  final double plantImageHeight;
  
  final double plantImageWidthFactor;
  
  final double bottomOffset;

  
  static int getStage(int level) {
    if (level <= 0) return 0;
    if (level == 1) return 1;
    return 2;
  }

  String get imagePath => images[0] ?? '';

  
  String resolvedImagePath(int currentPhase) {
    final stage = getStage(currentPhase);
    return images[stage] ??
        images[2] ??
        images[1] ??
        images[0] ??
        images.values.first;
  }

  static const List<GardenPlantOption> choices = [
    GardenPlantOption(
      id: 'forget_me_not',
      name: 'Forget Me Not',
      description: 'it lingers, though not as it once was',
      images: {
        0: 'assets/images/plants/forget_me_not/forget_me_not_seed.png',
        1: 'assets/images/plants/forget_me_not/forget_me_not_grow.png',
        2: 'assets/images/plants/forget_me_not/forget_me_not_full.png',
      },
      bottomOffset: 2,
      plantPhaseScaleFactor: 1.45,
    ),
    GardenPlantOption(
      id: 'allium',
      name: 'Allium',
      description: 'It rises slowly, holding itself together in quiet balance.',
      images: {
        0: 'assets/images/plants/allium/allium_seed.png',
        1: 'assets/images/plants/allium/allium_grow.png',
        2: 'assets/images/plants/allium/allium_full.png',
      },
      plantImageHeight: 216,
      bottomOffset: 0,
      plantPhaseScaleFactor: 1.35,
    ),
    GardenPlantOption(
      id: 'rose',
      name: 'Rose',
      description: 'growth shaped by both light and weight',
      images: {
        0: 'assets/images/plants/rose/rose_seed.png',
        1: 'assets/images/plants/rose/rose_grow.png',
        2: 'assets/images/plants/rose/rose_full.png',
      },
      bottomOffset: 11,
      plantPhaseScaleFactor: 1.45,
    ),
    GardenPlantOption(
      id: 'camellia',
      name: 'Camellia',
      description: 'beauty that exists without needing to be seen',
      images: {
        0: 'assets/images/plants/camellia/camellia_seed.png',
        1: 'assets/images/plants/camellia/camellia_grown.png',
        2: 'assets/images/plants/camellia/camellia_full.png',
      },
      bottomOffset: 10,
      plantPhaseScaleFactor: 1.45,
    ),
    GardenPlantOption(
      id: 'iris',
      name: 'Iris',
      description: 'strength that moves in silence',
      images: {
        0: 'assets/images/plants/iris/iris_seed.png',
        1: 'assets/images/plants/iris/iris_grow.png',
        2: 'assets/images/plants/iris/iris_full.png',
      },
      plantImageHeight: 208,
      bottomOffset: 16,
      plantPhaseScaleFactor: 1.45,
    ),
    GardenPlantOption(
      id: 'ranunculus',
      name: 'Ranunculus',
      description: 'unfolding slowly, layer by layer',
      images: {
        0: 'assets/images/plants/ranunculus/ranunculus_seed.png',
        1: 'assets/images/plants/ranunculus/ranunculus_grow.png',
        2: 'assets/images/plants/ranunculus/ranunculus_full.png',
      },
      plantImageHeight: 204,
      bottomOffset: 13,
      plantPhaseScaleFactor: 1.45,
    ),
  ];
}
