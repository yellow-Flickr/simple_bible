/// Fixed facts about the app used by the Profile and About screens.
abstract final class AppInfo {
  static const name = 'Simple Bible';

  /// Must match `applicationId` in android/app/build.gradle.
  static const androidPackage = 'com.codekraft.simple_bible';

  static const company = 'CodeKraft';
  static const copyright = '© 2026 $company. All rights reserved.';

  static const feedbackEmail = 'c0d3.kraft@gmail.com';

  // TODO: confirm the Buy Me a Coffee handle.
  static const supportUrl = 'https://buymeacoffee.com/c0d3kraft';

  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackage';
  static const playStoreAppUrl = 'market://details?id=$androidPackage';


  static const siteBaseUrl =
      'https://yellow-flickr.github.io/simple-bible-catalogue';
  static const privacyUrl = '$siteBaseUrl/privacy-policy/';
  static const termsUrl = '$siteBaseUrl/terms-of-use/';
  static const licenseUrl = '$siteBaseUrl/license/';
  static const changelogUrl = '$siteBaseUrl/changelog/';

  static const shareMessage =
      'Read, search and reflect on the Bible in your language with $name.'
      '\n$playStoreUrl';
}
