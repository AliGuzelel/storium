
class SavedImageEntry {
  const SavedImageEntry({
    required this.path,
    this.caption,
  });

  final String path;
  final String? caption;

  Map<String, dynamic> toJson() => {
        'path': path,
        if (caption != null && caption!.isNotEmpty) 'caption': caption,
      };

  factory SavedImageEntry.fromJson(Map<String, dynamic> json) {
    final path = json['path'] as String? ?? '';
    final cap = json['caption'] as String?;
    return SavedImageEntry(
      path: path,
      caption: (cap != null && cap.isNotEmpty) ? cap : null,
    );
  }
}
