import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../effects/cherry_blossom_effect.dart';
import '../garden/garden_models.dart';
import '../pages/collection_constants.dart';

/// Best-effort precache for garden + pink theme raster assets to avoid decode
/// spikes and reduce "Unable to load asset" flashes after long sessions.
Future<void>? _precacheFuture;

Future<void> precacheStoriumRasterAssets(BuildContext context) async {
  _precacheFuture ??= _precacheStoriumRasterAssetsImpl(context);
  await _precacheFuture;
}

Future<void> _precacheStoriumRasterAssetsImpl(BuildContext context) async {
  if (!context.mounted) return;
  final paths = <String>[
    CherryBlossomEffect.assetPath,
    'assets/images/wateringcan.png',
    for (final o in GardenPlantOption.choices) ...[
      o.imagePath,
      ...o.images.values,
    ],
    kSpaceCollectionGridPreviewAsset,
    kNatureCollectionGridPreviewAsset,
    kArtCollectionGridPreviewAsset,
    kOceanCollectionGridPreviewAsset,
    for (final p in kSpaceCollectionImageAssets)
      if (p != null) p,
    for (final p in kNatureCollectionImageAssets)
      if (p != null) p,
    for (final p in kArtCollectionImageAssets)
      if (p != null) p,
    for (final p in kOceanCollectionImageAssets)
      if (p != null) p,
    for (final p in kAnimalCollectionImageAssets)
      if (p != null) p,
    ...await _storyAssetPaths(),
  ];
  final uniquePaths = paths.toSet();
  for (final path in uniquePaths) {
    if (!context.mounted) return;
    try {
      await precacheImage(AssetImage(path), context);
    } catch (e, st) {
      debugPrint('precacheImage failed for $path: $e\n$st');
    }
  }
}

Future<List<String>> _storyAssetPaths() async {
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets().where(_isStoryImageAsset).toList();
  } catch (e, st) {
    debugPrint('AssetManifest load failed for story assets: $e\n$st');
    return const <String>[];
  }
}

bool _isStoryImageAsset(String path) {
  if (!path.startsWith('assets/images/stories/')) return false;
  return path.endsWith('.png') ||
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.webp');
}
