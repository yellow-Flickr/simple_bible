import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_bible/user_space/app_info.dart';
import 'package:url_launcher/url_launcher.dart';

/// The installed app's version, e.g. "0.1.0 (1)".
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

Future<void> shareApp(BuildContext context) async {
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      text: AppInfo.shareMessage,
      subject: AppInfo.name,
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}

/// Opens the Play Store listing, falling back to the web page when the
/// store app isn't available.
Future<void> rateApp(BuildContext context) async {
  final opened = await _tryLaunch(Uri.parse(AppInfo.playStoreAppUrl)) ||
      await _tryLaunch(Uri.parse(AppInfo.playStoreUrl));
  if (!opened && context.mounted) _notify(context, "Couldn't open the store.");
}

Future<void> sendFeedback(BuildContext context, WidgetRef ref) async {
  final version = ref.read(appVersionProvider).valueOrNull ?? 'unknown';
  // Built by hand: Uri.queryParameters encodes spaces as "+", which mail
  // apps show literally.
  final uri = Uri.parse(
    'mailto:${AppInfo.feedbackEmail}'
    '?subject=${Uri.encodeComponent('${AppInfo.name} feedback')}'
    '&body=${Uri.encodeComponent('\n\n---\n${AppInfo.name} $version')}',
  );
  if (!await _tryLaunch(uri) && context.mounted) {
    _notify(context, 'No email app found. Write to ${AppInfo.feedbackEmail}');
  }
}

Future<void> openLink(BuildContext context, String url) async {
  if (!await _tryLaunch(Uri.parse(url)) && context.mounted) {
    _notify(context, "Couldn't open $url");
  }
}

Future<bool> _tryLaunch(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

void _notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
