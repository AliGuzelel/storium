import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

import '../providers/settings_manager.dart';

class RuntimeTextLocalizer {
  RuntimeTextLocalizer._();

  static final GoogleTranslator _translator = GoogleTranslator();
  static final Map<String, String> _cache = <String, String>{};

  static Future<String> localize(BuildContext context, String text) async {
    final lang = context.read<SettingsManager>().language;
    return localizeForLanguage(lang: lang, text: text);
  }

  static Future<String> localizeForLanguage({
    required String lang,
    required String text,
  }) async {
    final input = text.trim();
    if (input.isEmpty) return text;
    if (lang != 'tr' && lang != 'ar') return text;

    final cacheKey = '$lang::$input';
    final cached = _cache[cacheKey];
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final translated = await _translator.translate(input, from: 'en', to: lang);
      final output = translated.text.trim();
      if (output.isEmpty) return text;
      _cache[cacheKey] = output;
      return output;
    } catch (_) {
      return text;
    }
  }
}
