import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/saved_images_store.dart';
import '../theme/ui_tokens.dart';
import '../widgets/safe_asset_image.dart';
import 'collection_constants.dart';

void _showTransientTopMessage(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      top: MediaQuery.paddingOf(ctx).top + 56,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  height: 1.35,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future<void>.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}

/// Full-screen swipeable gallery for a fixed-slot collection (e.g. Animals, Space).
class AnimalGalleryViewerPage extends StatefulWidget {
  const AnimalGalleryViewerPage({
    super.key,
    required this.initialIndex,
    this.imageAssets,
    this.captionForIndex,
    this.tilePlaceholderColors,
  });

  final int initialIndex;
  /// Defaults to [kAnimalCollectionImageAssets] when omitted.
  final List<String?>? imageAssets;
  /// Defaults to [animalCollectionViewerCaption] when omitted.
  final String? Function(int index)? captionForIndex;
  /// Colors for empty slots; defaults to [kAnimalPlaceholderTileColors].
  final List<Color>? tilePlaceholderColors;

  @override
  State<AnimalGalleryViewerPage> createState() =>
      _AnimalGalleryViewerPageState();
}

class _AnimalGalleryViewerPageState extends State<AnimalGalleryViewerPage> {
  late final PageController _pageController;
  late int _currentIndex;

  List<String?> get _assets =>
      widget.imageAssets ?? kAnimalCollectionImageAssets;

  List<Color> get _placeholderColors =>
      widget.tilePlaceholderColors ?? kAnimalPlaceholderTileColors;

  String? _captionFor(int index) => widget.captionForIndex != null
      ? widget.captionForIndex!(index)
      : animalCollectionViewerCaption(index);

  @override
  void initState() {
    super.initState();
    final list = _assets;
    final i = widget.initialIndex.clamp(0, list.length - 1);
    _currentIndex = i;
    _pageController = PageController(initialPage: i);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = _assets.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: n,
            itemBuilder: (context, index) {
              final path = _assets[index];
              if (path != null) {
                final caption = _captionFor(index);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 64, 12, 24),
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final hasCaption =
                            caption != null && caption.isNotEmpty;
                        final textBlock = hasCaption ? 52.0 : 0.0;
                        final maxImgH = (c.maxHeight - textBlock - 12)
                            .clamp(80.0, c.maxHeight);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: maxImgH,
                                maxWidth: c.maxWidth,
                              ),
                              child: SafeAssetImage(
                                path,
                                fit: BoxFit.contain,
                              ),
                            ),
                            if (hasCaption) ...[
                              const SizedBox(height: 12),
                              Text(
                                caption,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                );
              }
              final bg = _placeholderColors[index % _placeholderColors.length];
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: UiTokens.surfaceBorderRadius,
                        border: Border.fromBorderSide(UiTokens.surfaceBorderSide),
                      ),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white.withValues(alpha: 0.45),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Photo ${index + 1}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Material(
                color: Colors.black.withValues(alpha: 0.65),
                child: SizedBox(
                  height: 52,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close',
                        ),
                        if (_assets[_currentIndex] != null) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.bookmark_add_outlined,
                                color: Colors.white),
                            tooltip: 'Save to My Space',
                            onPressed: () async {
                              final path = _assets[_currentIndex]!;
                              final cap = _captionFor(_currentIndex);
                              final added = await context
                                  .read<SavedImagesStore>()
                                  .add(path, caption: cap);
                              if (!context.mounted) return;
                              _showTransientTopMessage(
                                context,
                                added
                                    ? 'Saved to My Space'
                                    : 'Already saved in My Space',
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
