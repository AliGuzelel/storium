import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/saved_images_store.dart';

/// Full-screen view for one saved image; close or remove from My Space.
class MySpaceImageViewerPage extends StatelessWidget {
  const MySpaceImageViewerPage({
    super.key,
    required this.imagePath,
    this.caption,
  });

  final String imagePath;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 64, 12, 24),
            child: Center(
              child: LayoutBuilder(
                builder: (context, c) {
                  final cap = caption?.trim();
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
                          imagePath,
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
                          cap!,
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
                                .remove(imagePath);
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
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
