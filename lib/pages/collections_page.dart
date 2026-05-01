import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/ui_tokens.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/safe_asset_image.dart';
import 'collection_constants.dart';
import 'collection_detail_page.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              UiTokens.pagePadding,
              12,
              UiTokens.pagePadding,
              UiTokens.pagePadding + 16,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final label = kCollectionTopicLabels[index];
                  final tint = kCollectionPlaceholderColors[index];
                  return _CollectionGridCard(
                    label: label,
                    placeholderColor: tint,
                    previewAssetPath: switch (label) {
                      'Animals' => kAnimalsCollectionGridPreviewAsset,
                      'Space' => kSpaceCollectionGridPreviewAsset,
                      'Nature' => kNatureCollectionGridPreviewAsset,
                      'Art' => kArtCollectionGridPreviewAsset,
                      'Ocean' => kOceanCollectionGridPreviewAsset,
                      'Music' => kMusicCollectionGridPreviewAsset,
                      'Memes' => kMemesCollectionGridPreviewAsset,
                      'Languages' => kLanguagesCollectionGridPreviewAsset,
                      'Cities' => kCitiesCollectionGridPreviewAsset,
                      _ => null,
                    },
                    fullBleedImage: label == 'Animals' ||
                        label == 'Space' ||
                        label == 'Nature' ||
                        label == 'Art' ||
                        label == 'Ocean' ||
                        label == 'Music' ||
                        label == 'Memes' ||
                        label == 'Languages' ||
                        label == 'Cities',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => CollectionDetailPage(title: label),
                        ),
                      );
                    },
                  );
                },
                childCount: kCollectionTopicLabels.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionGridCard extends StatelessWidget {
  const _CollectionGridCard({
    required this.label,
    required this.placeholderColor,
    this.previewAssetPath,
    this.fullBleedImage = false,
    required this.onTap,
  });

  final String label;
  final Color placeholderColor;
  
  final String? previewAssetPath;
  
  final bool fullBleedImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final path = previewAssetPath;
    if (fullBleedImage && path != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: UiTokens.surfaceBorderRadius,
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: ClipRRect(
            borderRadius: UiTokens.surfaceBorderRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: UiTokens.surfaceBorderRadius,
                border: Border.fromBorderSide(UiTokens.surfaceBorderSide),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox.expand(
                child: SafeAssetImage(
                  path,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: UiTokens.surfaceBorderRadius,
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: ClipRRect(
          borderRadius: UiTokens.surfaceBorderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: UiTokens.surfaceBorderRadius,
                border: Border.fromBorderSide(UiTokens.surfaceBorderSide),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: UiTokens.surfaceBorderRadius,
                        child: switch (previewAssetPath) {
                          final path? => SizedBox.expand(
                              child: SafeAssetImage(
                                path,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                          _ => DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: UiTokens.surfaceBorderRadius,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      placeholderColor.withValues(alpha: 0.55),
                                      placeholderColor.withValues(alpha: 0.28),
                                    ],
                                  ),
                                ),
                            ),
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                      child: Center(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
