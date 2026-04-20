import 'package:flutter/material.dart';

/// Space-style insets for every collection detail grid / body.
const double kCollectionDetailGridTopInset = 16;
const double kCollectionDetailGridHorizontalInset = 4;

/// Category titles for the collections grid (9 items, UI only).
const List<String> kCollectionTopicLabels = [
  'Animals',
  'Space',
  'Nature',
  'Art',
  'Ocean',
  'Music',
  'Memes',
  'Languages',
  'Superpowers',
];

/// Collections grid: Space card uses [space13] instead of a flat color block.
const String kSpaceCollectionGridPreviewAsset =
    'assets/collection_images/space/space13.jpg';

/// Collections grid: Nature card full-bleed preview ([nature15]).
const String kNatureCollectionGridPreviewAsset =
    'assets/collection_images/nature/nature15.jpg';

/// Collections grid: Art card full-bleed preview ([art15]; detail uses [art1]–[art14] only).
const String kArtCollectionGridPreviewAsset =
    'assets/collection_images/art/art15.jpg';

/// Collections grid: Ocean card full-bleed preview ([ocean19]; detail uses [ocean1]–[ocean18] only).
const String kOceanCollectionGridPreviewAsset =
    'assets/collection_images/ocean/ocean19.jpg';

/// Space collection: 12 images (3×4) in [assets/collection_images/space].
const List<String?> kSpaceCollectionImageAssets = <String?>[
  'assets/collection_images/space/space1.jpg',
  'assets/collection_images/space/space2.jpg',
  'assets/collection_images/space/space3.jpg',
  'assets/collection_images/space/space4.jpg',
  'assets/collection_images/space/space5.jpg',
  'assets/collection_images/space/space6.jpg',
  'assets/collection_images/space/space7.jpg',
  'assets/collection_images/space/space8.jpg',
  'assets/collection_images/space/space9.jpg',
  'assets/collection_images/space/space10.jpg',
  'assets/collection_images/space/space11.jpg',
  'assets/collection_images/space/space12.jpg',
];

/// Muted tile colors for space grid fallbacks (cycles by index).
const List<Color> kSpacePlaceholderTileColors = [
  Color(0xFF3D4F6B),
  Color(0xFF4A5D7C),
  Color(0xFF354A66),
  Color(0xFF52688A),
  Color(0xFF2E3F5C),
  Color(0xFF455A78),
];

/// Nature collection: 14 images in [assets/collection_images/nature] (3 columns; scroll on detail page).
const List<String?> kNatureCollectionImageAssets = <String?>[
  'assets/collection_images/nature/nature1.jpg',
  'assets/collection_images/nature/nature2.jpg',
  'assets/collection_images/nature/nature3.jpg',
  'assets/collection_images/nature/nature4.jpg',
  'assets/collection_images/nature/nature5.jpg',
  'assets/collection_images/nature/nature6.jpg',
  'assets/collection_images/nature/nature7.jpg',
  'assets/collection_images/nature/nature8.jpg',
  'assets/collection_images/nature/nature9.jpg',
  'assets/collection_images/nature/nature10.jpg',
  'assets/collection_images/nature/nature11.jpg',
  'assets/collection_images/nature/nature12.jpg',
  'assets/collection_images/nature/nature13.jpg',
  'assets/collection_images/nature/nature14.jpg',
];

/// Muted tile colors for nature grid fallbacks (cycles by index).
const List<Color> kNaturePlaceholderTileColors = [
  Color(0xFF4A6B52),
  Color(0xFF5A7D62),
  Color(0xFF3D5A44),
  Color(0xFF6A8F72),
  Color(0xFF355040),
  Color(0xFF527A5C),
];

/// Art collection: 14 images in [assets/collection_images/art] ([art1] is png; [art2]–[art14] jpg).
const List<String?> kArtCollectionImageAssets = <String?>[
  'assets/collection_images/art/art1.png',
  'assets/collection_images/art/art2.jpg',
  'assets/collection_images/art/art3.jpg',
  'assets/collection_images/art/art4.jpg',
  'assets/collection_images/art/art5.jpg',
  'assets/collection_images/art/art6.jpg',
  'assets/collection_images/art/art7.jpg',
  'assets/collection_images/art/art8.jpg',
  'assets/collection_images/art/art9.jpg',
  'assets/collection_images/art/art10.jpg',
  'assets/collection_images/art/art11.jpg',
  'assets/collection_images/art/art12.jpg',
  'assets/collection_images/art/art13.jpg',
  'assets/collection_images/art/art14.jpg',
];

/// Muted tile colors for art grid fallbacks (cycles by index).
const List<Color> kArtPlaceholderTileColors = [
  Color(0xFF6B5A78),
  Color(0xFF7A6488),
  Color(0xFF5A4A68),
  Color(0xFF8A7298),
  Color(0xFF4A3D58),
  Color(0xFF756090),
];

/// Ocean collection: 18 images in [assets/collection_images/ocean] (3 columns; scroll on detail page).
const List<String?> kOceanCollectionImageAssets = <String?>[
  'assets/collection_images/ocean/ocean1.jpg',
  'assets/collection_images/ocean/ocean2.jpg',
  'assets/collection_images/ocean/ocean3.jpg',
  'assets/collection_images/ocean/ocean4.jpg',
  'assets/collection_images/ocean/ocean5.jpg',
  'assets/collection_images/ocean/ocean6.jpg',
  'assets/collection_images/ocean/ocean7.jpg',
  'assets/collection_images/ocean/ocean8.jpg',
  'assets/collection_images/ocean/ocean9.jpg',
  'assets/collection_images/ocean/ocean10.jpg',
  'assets/collection_images/ocean/ocean11.jpg',
  'assets/collection_images/ocean/ocean12.jpg',
  'assets/collection_images/ocean/ocean13.jpg',
  'assets/collection_images/ocean/ocean14.jpg',
  'assets/collection_images/ocean/ocean15.jpg',
  'assets/collection_images/ocean/ocean16.jpg',
  'assets/collection_images/ocean/ocean17.jpg',
  'assets/collection_images/ocean/ocean18.jpg',
];

/// Muted tile colors for ocean grid fallbacks (cycles by index).
const List<Color> kOceanPlaceholderTileColors = [
  Color(0xFF3D6B7A),
  Color(0xFF4A7D8F),
  Color(0xFF2E5A68),
  Color(0xFF5A8FA0),
  Color(0xFF356878),
  Color(0xFF4A8FA8),
];

/// Animals collection: 12 separate cells (3×4). `null` = no image yet (colored tile).
const List<String?> kAnimalCollectionImageAssets = <String?>[
  'assets/collection_images/animals/animal1.jpg',
  'assets/collection_images/animals/animal2.jpg',
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
];

/// Caption shown under the image in the full-screen animal viewer only (not on the grid).
String? animalCollectionViewerCaption(int index) {
  switch (index) {
    case 0:
      return 'This is animal 1';
    case 1:
      return 'This is animal 2';
    default:
      return null;
  }
}

/// Muted tile colors for empty animal slots (cycles by index).
const List<Color> kAnimalPlaceholderTileColors = [
  Color(0xFF5A7D6A),
  Color(0xFF6B8E7E),
  Color(0xFF4A6B5C),
  Color(0xFF7A9E8B),
  Color(0xFF556B5A),
  Color(0xFF6A8F7E),
];

/// Soft placeholder tints behind each card (no images).
const List<Color> kCollectionPlaceholderColors = [
  Color(0xFF6B8E7E),
  Color(0xFF5C6B9A),
  Color(0xFF7A9E6B),
  Color(0xFF9B7A9E),
  Color(0xFF4A8FA8),
  Color(0xFF7B6BA8),
  Color(0xFFB88A5C),
  Color(0xFF8A7BA6),
  Color(0xFF7D8B7A),
];
