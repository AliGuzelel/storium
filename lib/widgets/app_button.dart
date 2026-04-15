import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Glass-style button using only [GestureDetector] (no [InkWell] splash).
/// Avoids ticker / ink-highlight crashes when [onTap] is async or rebuilds
/// happen quickly (e.g. garden cooldown timer + [setState]).
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 48,
    this.borderRadius,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(18);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.onTap == null
              ? null
              : (_) => setState(() => _pressed = true),
          onTapUp: widget.onTap == null
              ? null
              : (_) => setState(() => _pressed = false),
          onTapCancel: widget.onTap == null
              ? null
              : () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: Container(
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: _pressed ? 0.20 : 0.26),
                  Colors.white.withValues(alpha: _pressed ? 0.10 : 0.14),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: _pressed ? 0.32 : 0.40,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
