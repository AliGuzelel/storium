import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/runtime_text_localizer.dart';
import '../providers/settings_manager.dart';

class LocalizedText extends StatelessWidget {
  const LocalizedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsManager>().language;
    if (lang != 'tr' && lang != 'ar') {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return FutureBuilder<String>(
      future: RuntimeTextLocalizer.localizeForLanguage(lang: lang, text: text),
      initialData: text,
      builder: (context, snapshot) {
        final output = snapshot.data ?? text;
        return Text(
          output,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
