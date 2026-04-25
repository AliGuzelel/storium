import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/saved_images_store.dart';

/// Full-screen swipeable view for all saved My Space images.
class MySpaceImageViewerPage extends StatefulWidget {
  const MySpaceImageViewerPage({
    super.key,
    required this.initialIndex,
  });

  final int initialIndex;

  @override
  State<MySpaceImageViewerPage> createState() => _MySpaceImageViewerPageState();
}

class _MySpaceImageViewerPageState extends State<MySpaceImageViewerPage> {
  PageController? _pageController;
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final entries = context.read<SavedImagesStore>().entries;
    if (entries.isEmpty) return;
    final safeIndex = widget.initialIndex.clamp(0, entries.length - 1);
    _pageController ??= PageController(initialPage: safeIndex);
    _currentIndex = safeIndex;
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<SavedImagesStore>().entries;
    if (entries.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const Scaffold(backgroundColor: Colors.black);
    }
    final controller = _pageController ??= PageController(
      initialPage: _currentIndex.clamp(0, entries.length - 1),
    );
    final active = entries[_currentIndex.clamp(0, entries.length - 1)];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: controller,
            itemCount: entries.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 64, 12, 24),
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final cap = entry.caption?.trim();
                      final hasCaption = cap != null && cap.isNotEmpty;
                      final textBlock = hasCaption ? 52.0 : 0.0;
                      final maxImgH =
                          (c.maxHeight - textBlock - 12).clamp(80.0, c.maxHeight);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: maxImgH,
                              maxWidth: c.maxWidth,
                            ),
                            child: Image.asset(
                              entry.path,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.broken_image_outlined,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          if (hasCaption) ...[
                            const SizedBox(height: 12),
                            Text(
                              cap,
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
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.white),
                          tooltip: 'Remove from My Space',
                          onPressed: () async {
                            await context
                                .read<SavedImagesStore>()
                                .remove(active.path);
                            if (!context.mounted) return;
                            final remaining = context.read<SavedImagesStore>().entries;
                            if (remaining.isEmpty) {
                              Navigator.of(context).pop();
                              return;
                            }
                            final nextIndex = _currentIndex.clamp(
                              0,
                              remaining.length - 1,
                            );
                            if (nextIndex != _currentIndex) {
                              setState(() => _currentIndex = nextIndex);
                            }
                            _pageController?.jumpToPage(nextIndex);
                          },
                        ),
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
