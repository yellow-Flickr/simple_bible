/// Fixed facts about the app used by the Profile and About screens.
abstract final class AppInfo {
  static const name = 'Simple Bible';

  /// Must match `applicationId` in android/app/build.gradle. Change both
  /// before publishing; `com.example` ids are rejected by the Play Store.
  static const androidPackage = 'com.example.simple_bible';

  // TODO: replace with the real support address before release.
  static const feedbackEmail = 'feedback@example.com';

  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackage';
  static const playStoreAppUrl = 'market://details?id=$androidPackage';

  static const shareMessage =
      'I read the Bible with $name: KJV and Akuapem Twi, topics, daily '
      'reflections and notes, all offline.\n$playStoreUrl';

  static const authors = [
    (name: 'Jeffrey Boahen', url: 'https://github.com/yellow-Flickr'),
    (name: 'Collins Brobbey', url: 'https://github.com/Qweku'),
  ];
}
