import 'package:flutter/material.dart';

class GardenSunWidget extends StatelessWidget {
  const GardenSunWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              top: 38,
              right: 28,
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFF7C9),
                      Color(0xFFFFEAA1),
                      Color(0x00FFEAA1),
                    ],
                    stops: [0.0, 0.58, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFEAA1).withValues(alpha: 0.42),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
