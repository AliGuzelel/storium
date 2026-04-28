import 'package:flutter/material.dart';


class SafeAssetImage extends StatelessWidget {
  const SafeAssetImage(
    this.assetName, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.low,
    this.isAntiAlias = true,
    this.semanticLabel,
    this.color,
    this.colorBlendMode,
  });

  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final FilterQuality filterQuality;
  final bool isAntiAlias;
  final String? semanticLabel;
  final Color? color;
  final BlendMode? colorBlendMode;

  static Widget _fallback(
    BuildContext context, {
    double? width,
    double? height,
  }) {
    final w = width ?? 48;
    final h = height ?? 48;
    return ColoredBox(
      color: Colors.black12,
      child: SizedBox(
        width: w,
        height: h,
        child: Icon(
          Icons.hide_image_outlined,
          size: (w < h ? w : h) * 0.45,
          color: Colors.white24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      isAntiAlias: isAntiAlias,
      semanticLabel: semanticLabel,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (c, _, __) => _fallback(c, width: width, height: height),
    );
  }
}
