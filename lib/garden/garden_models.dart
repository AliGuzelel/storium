import 'dart:convert';

/// Persisted garden state (local cache + Firestore `gardenJson`).
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
  /// Current [PageView] index for the garden (restored on load).
  final int selectedPlantPageIndex;
  final int fertilizerCount;

  static List<String> get allPlantIds =>
      GardenPlantOption.choices.map((e) => e.id).toList();

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
          },
      ],
    };
  }

  factory GardenPersistedState.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'] as Map<String, dynamic>? ?? {};
    final slots = <String, GardenPlantSlot>{
      for (final id in allPlantIds)
        id: GardenPlantSlot.fromJson(
          Map<String, dynamic>.from(
            rawSlots[id] as Map? ?? const {},
          ),
        ),
    };
    final rawDone = json['completedPlantTypes'] as List<dynamic>? ?? const [];
    final completed = rawDone.map((e) => e.toString()).toSet();
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
    required this.imagePath,
    this.plantImageHeight = 200,
    this.plantImageWidthFactor = 0.88,
    this.bottomOffset = 0,
  });

  final String id;
  final String name;
  final String description;
  final String imagePath;
  /// Fixed layout height for the plant [Image] box ([BoxFit.contain] avoids stretch).
  final double plantImageHeight;
  /// Fraction of page width used as max width for the plant box.
  final double plantImageWidthFactor;
  /// Pushes the raster down (+Y) to cancel transparent padding under the stem in the PNG.
  final double bottomOffset;

  static const List<GardenPlantOption> choices = [
    GardenPlantOption(
      id: 'forget_me_not',
      name: 'Forget Me Not',
      description: 'it lingers, though not as it once was',
      imagePath: 'assets/images/plants/forget_me_not.png',
      bottomOffset: 12,
    ),
    GardenPlantOption(
      id: 'lavender',
      name: 'Lavender',
      description: 'peace that settles without asking',
      imagePath: 'assets/images/plants/lavender.png',
      plantImageHeight: 216,
      bottomOffset: 14,
    ),
    GardenPlantOption(
      id: 'rose',
      name: 'Rose',
      description: 'growth shaped by both light and weight',
      imagePath: 'assets/images/plants/rose.png',
      bottomOffset: 11,
    ),
    GardenPlantOption(
      id: 'camellia',
      name: 'Camellia',
      description: 'beauty that exists without needing to be seen',
      imagePath: 'assets/images/plants/camellia.png',
      bottomOffset: 10,
    ),
    GardenPlantOption(
      id: 'iris',
      name: 'Iris',
      description: 'strength that moves in silence',
      imagePath: 'assets/images/plants/iris.png',
      plantImageHeight: 208,
      bottomOffset: 16,
    ),
    GardenPlantOption(
      id: 'ranunculus',
      name: 'Ranunculus',
      description: 'unfolding slowly, layer by layer',
      imagePath: 'assets/images/plants/ranunculus.png',
      plantImageHeight: 204,
      bottomOffset: 13,
    ),
  ];
}
