/// Shared Firebase project identifiers (REST + Auth).
class FirebaseProjectConfig {
  static const String apiKey = 'AIzaSyAlISRVS8IBLbRJy-0whlGJ0dWLvX3UuBg';
  static const String projectId = 'storium-6083e';

  static String get firestoreDocumentsBase =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  static Uri userDocumentUri(String uid) => Uri.parse(
        '$firestoreDocumentsBase/users/$uid?key=$apiKey',
      );
}
