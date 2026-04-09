class SettingsModel {
  final double textScale;
  final String language;
  final String themeColor;
  final bool isDarkMode;
  final double musicVolume;
  final double soundVolume;

  const SettingsModel({
    this.textScale = 1.0,
    this.language = 'en',
    this.themeColor = 'purple',
    this.isDarkMode = false,
    this.musicVolume = 50,
    this.soundVolume = 50,
  });

  SettingsModel copyWith({
    double? textScale,
    String? language,
    String? themeColor,
    bool? isDarkMode,
    double? musicVolume,
    double? soundVolume,
  }) {
    return SettingsModel(
      textScale: textScale ?? this.textScale,
      language: language ?? this.language,
      themeColor: themeColor ?? this.themeColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      musicVolume: musicVolume ?? this.musicVolume,
      soundVolume: soundVolume ?? this.soundVolume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'textScale': textScale,
      'language': language,
      'themeColor': themeColor,
      'isDarkMode': isDarkMode,
      'musicVolume': musicVolume,
      'soundVolume': soundVolume,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      language: (json['language'] as String?) ?? 'en',
      themeColor: (json['themeColor'] as String?) ?? 'purple',
      isDarkMode: (json['isDarkMode'] as bool?) ?? false,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 50,
      soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 50,
    );
  }
}
