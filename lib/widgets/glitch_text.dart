import 'package:flutter/material.dart';

class GlitchText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const GlitchText({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(2, 0),
          child: Text(text, style: style.copyWith(color: Colors.cyanAccent)),
        ),
        Transform.translate(
          offset: const Offset(-2, 0),
          child: Text(text, style: style.copyWith(color: Colors.pinkAccent)),
        ),
        Text(text, style: style.copyWith(color: Colors.black)),
      ],
    );
  }
}
