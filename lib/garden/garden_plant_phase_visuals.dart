// Visual simulation of growth when using a single image per plant.

double getScale(int phase) {
  switch (phase.clamp(0, 3)) {
    case 0:
      return 0.275;
    case 1:
      return 0.55;
    case 2:
      return 0.8;
    case 3:
      return 1.0;
    default:
      return 1.0;
  }
}

double getOpacity(int phase) {
  switch (phase.clamp(0, 3)) {
    case 0:
      return 0.45;
    case 1:
      return 0.7;
    case 2:
      return 0.9;
    case 3:
      return 1.0;
    default:
      return 1.0;
  }
}

/// Shared duration for phase scale/opacity transitions (calm, readable).
Duration get gardenPlantPhaseTransitionDuration =>
    const Duration(milliseconds: 520);
