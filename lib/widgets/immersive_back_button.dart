import 'package:flutter/material.dart';

class ImmersiveBackButton extends StatelessWidget {
  const ImmersiveBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12),
        child: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              foregroundColor: Colors.white,
            ),
            onPressed: onPressed ?? () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
          ),
        ),
      ),
    );
  }
}
