import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/ui_tokens.dart';
import '../widgets/gradient_scaffold.dart';
import 'animal_gallery_viewer_page.dart';
import 'collection_constants.dart';

/// Placeholder detail for a collection category (navigation only for now).
class CollectionDetailPage extends StatelessWidget {
  const CollectionDetailPage({super.key, required this.title});

  final String title;

  static const int _collectionGridCrossAxisCount = 3;
  static const int _collectionGridRowCount = 4;
  static const double _collectionGridCrossSpacing = 6;
  static const double _collectionGridMainSpacing = 6;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Cinzel', fontSize: 20),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.04),
        elevation: 0,
      ),
      body: switch (title) {
        'Animals' => _buildAnimalsFullPageGrid(context),
        'Space' => _buildSpaceFullPageGrid(context),
        'Nature' => _buildNatureFullPageGrid(context),
        'Art' => _buildArtFullPageGrid(context),
        'Ocean' => _buildOceanFullPageGrid(context),
        _ => _buildDefaultCollectionBody(context),
      },
    );
  }

  /// Fills all space below the app bar; rows stretch so the grid reaches the bottom.
  Widget _buildAnimalsFullPageGrid(BuildContext context) {
    return _buildCollectionAssetGrid(
      context,
      assetPaths: kAnimalCollectionImageAssets,
      placeholderColors: kAnimalPlaceholderTileColors,
      emptyIcon: Icons.image_not_supported_outlined,
      thinBorderAroundImage: true,
      buildViewer: (index) => AnimalGalleryViewerPage(
        initialIndex: index,
        imageAssets: kAnimalCollectionImageAssets,
        captionForIndex: animalCollectionViewerCaption,
        tilePlaceholderColors: kAnimalPlaceholderTileColors,
      ),
    );
  }

  Widget _buildSpaceFullPageGrid(BuildContext context) {
    return _buildCollectionAssetGrid(
      context,
      assetPaths: kSpaceCollectionImageAssets,
      placeholderColors: kSpacePlaceholderTileColors,
      emptyIcon: Icons.image_not_supported_outlined,
      thinBorderAroundImage: true,
      buildViewer: (index) => AnimalGalleryViewerPage(
        initialIndex: index,
        imageAssets: kSpaceCollectionImageAssets,
        captionForIndex: (_) => null,
        tilePlaceholderColors: kSpacePlaceholderTileColors,
      ),
    );
  }

  Widget _buildNatureFullPageGrid(BuildContext context) {
    return _buildCollectionAssetGrid(
      context,
      assetPaths: kNatureCollectionImageAssets,
      placeholderColors: kNaturePlaceholderTileColors,
      emptyIcon: Icons.image_not_supported_outlined,
      thinBorderAroundImage: true,
      scrollable: true,
      buildViewer: (index) => AnimalGalleryViewerPage(
        initialIndex: index,
        imageAssets: kNatureCollectionImageAssets,
        captionForIndex: (_) => null,
        tilePlaceholderColors: kNaturePlaceholderTileColors,
      ),
    );
  }

  Widget _buildArtFullPageGrid(BuildContext context) {
    return _buildCollectionAssetGrid(
      context,
      assetPaths: kArtCollectionImageAssets,
      placeholderColors: kArtPlaceholderTileColors,
      emptyIcon: Icons.image_not_supported_outlined,
      thinBorderAroundImage: true,
      scrollable: true,
      buildViewer: (index) => AnimalGalleryViewerPage(
        initialIndex: index,
        imageAssets: kArtCollectionImageAssets,
        captionForIndex: (_) => null,
        tilePlaceholderColors: kArtPlaceholderTileColors,
      ),
    );
  }

  Widget _buildOceanFullPageGrid(BuildContext context) {
    return _buildCollectionAssetGrid(
      context,
      assetPaths: kOceanCollectionImageAssets,
      placeholderColors: kOceanPlaceholderTileColors,
      emptyIcon: Icons.image_not_supported_outlined,
      thinBorderAroundImage: true,
      scrollable: true,
      buildViewer: (index) => AnimalGalleryViewerPage(
        initialIndex: index,
        imageAssets: kOceanCollectionImageAssets,
        captionForIndex: (_) => null,
        tilePlaceholderColors: kOceanPlaceholderTileColors,
      ),
    );
  }

  Widget _buildCollectionAssetGrid(
    BuildContext context, {
    required List<String?> assetPaths,
    required List<Color> placeholderColors,
    required IconData emptyIcon,
    required bool thinBorderAroundImage,
    required Widget Function(int index) buildViewer,
    /// When true, grid scrolls vertically; tile size matches Space ([_collectionGridRowCount] rows in viewport).
    bool scrollable = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final innerW =
            (w - 2 * kCollectionDetailGridHorizontalInset)
                .clamp(1.0, double.infinity);
        final innerH =
            (h - kCollectionDetailGridTopInset).clamp(1.0, double.infinity);

        final cc = _collectionGridCrossAxisCount;
        final rc = _collectionGridRowCount;
        final cs = _collectionGridCrossSpacing;
        final ms = _collectionGridMainSpacing;

        final cellW = (innerW - (cc - 1) * cs) / cc;
        final cellH = (innerH - (rc - 1) * ms) / rc;
        /// Same cell geometry as Space so scrollable collections (e.g. Nature) fill the width and row height.
        final childAspectRatio = (cellW / cellH).clamp(0.01, 100.0);
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final safeCellW = cellW.isFinite && cellW > 0 ? cellW : innerW / cc;
        final decodeCacheWidth = (safeCellW * dpr).round().clamp(64, 4096);

        Widget cellImage(String path, int index) {
          final err = ColoredBox(
            color: placeholderColors[index % placeholderColors.length],
            child: Center(
              child: Icon(
                emptyIcon,
                color: Colors.white.withValues(alpha: 0.55),
                size: 32,
              ),
            ),
          );
          final core = Image.asset(
            path,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            cacheWidth: decodeCacheWidth,
            errorBuilder: (_, __, ___) => err,
          );
          final expanded = SizedBox.expand(child: core);
          if (!thinBorderAroundImage) return expanded;
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: UiTokens.surfaceBorderRadius,
              border: Border.fromBorderSide(UiTokens.surfaceBorderSide),
            ),
            child: expanded,
          );
        }

        final grid = GridView.builder(
          padding: scrollable
              ? const EdgeInsets.only(bottom: 28)
              : EdgeInsets.zero,
          physics: scrollable
              ? const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                )
              : const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cc,
            crossAxisSpacing: cs,
            mainAxisSpacing: ms,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: assetPaths.length,
          itemBuilder: (context, index) {
            final path = assetPaths[index];
            final radius =
                thinBorderAroundImage ? UiTokens.surfaceBorderRadius : null;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: radius,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => buildViewer(index),
                    ),
                  );
                },
                child: path != null
                    ? cellImage(path, index)
                    : Container(
                        decoration: thinBorderAroundImage
                            ? BoxDecoration(
                                borderRadius: radius,
                                border: Border.fromBorderSide(
                                  UiTokens.surfaceBorderSide,
                                ),
                                color: placeholderColors[
                                    index % placeholderColors.length],
                              )
                            : null,
                        color: thinBorderAroundImage
                            ? null
                            : placeholderColors[
                                index % placeholderColors.length],
                        alignment: Alignment.center,
                        child: Icon(
                          emptyIcon,
                          color: Colors.white.withValues(alpha: 0.35),
                          size: 28,
                        ),
                      ),
              ),
            );
          },
        );

        return Padding(
          padding: const EdgeInsets.only(
            top: kCollectionDetailGridTopInset,
            left: kCollectionDetailGridHorizontalInset,
            right: kCollectionDetailGridHorizontalInset,
          ),
          child: SizedBox(
            width: double.infinity,
            height: innerH,
            child: grid,
          ),
        );
      },
    );
  }

  Widget _buildDefaultCollectionBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: kCollectionDetailGridTopInset,
            left: kCollectionDetailGridHorizontalInset,
            right: kCollectionDetailGridHorizontalInset,
            bottom: UiTokens.pagePadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ClipRRect(
                  borderRadius: UiTokens.surfaceBorderRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: UiTokens.surfaceBorderRadius,
                        border: Border.fromBorderSide(UiTokens.surfaceBorderSide),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: UiTokens.surfaceBorderRadius,
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _collectionPlaceholderColor(title),
                                borderRadius: UiTokens.surfaceBorderRadius,
                                border: Border.fromBorderSide(
                                  UiTokens.surfaceBorderSide,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Stories for $title will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              height: 1.45,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Color _collectionPlaceholderColor(String title) {
  final i = kCollectionTopicLabels.indexOf(title);
  if (i < 0) {
    return Colors.grey[300]!.withValues(alpha: 0.45);
  }
  return kCollectionPlaceholderColors[i].withValues(alpha: 0.55);
}
