import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show installedVersionsProvider;
import 'package:simple_bible/version_store/application/version_store_controller.dart'
    show catalogueProvider;
import 'package:simple_bible/user_space/app_info.dart';
import 'package:simple_bible/user_space/presentation/about/app_actions.dart';
import 'package:simple_bible/shared/widgets/settings_section.dart';

/// Adds licences for bundled assets that don't come from a package, so they
/// show up on the licence page next to the package licences.
void registerAssetLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(['Meteocons'], _meteoconsLicense);
  });
}

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: kToolbarHeight - 2.h,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 4.h),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('asset/launchIcon.png', width: 20.w),
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            AppInfo.name,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          if (version != null)
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _copyVersion(context, version),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: .3.h),
                  child: Text(
                    'Version $version',
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                  ),
                ),
              ),
            ),
          SizedBox(height: 1.5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              "God's Word, in the language of your heart. Read and search "
              'Scripture, explore it by topic, pause for a daily reflection '
              'and keep your own notes, with new translations added as they '
              'become available.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ),
          SettingsSection(
            title: 'Acknowledgements',
            children: [
              ListTile(
                leading: const Icon(Icons.local_offer_outlined),
                title: const Text('DailyVerses.net'),
                subtitle: const Text(
                  'Topics and their verse collections are based on the '
                  'topical index at DailyVerses.net. Thank you for making '
                  'Scripture easy to explore.',
                ),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => openLink(context, 'https://dailyverses.net'),
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Bible translations'),
                subtitle: const Text(
                  'Each translation belongs to its rights holder. See who '
                  'they are and the licence for each.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTranslationCredits(context),
              ),
              ListTile(
                leading: const Icon(Icons.animation_outlined),
                title: const Text('Animations'),
                subtitle: const Text(
                  'From the LottieFiles community, including Meteocons by '
                  'Bas Milius.',
                ),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => openLink(context, 'https://lottiefiles.com'),
              ),
            ],
          ),
          SettingsSection(
            title: 'Legal',
            children: [
              ListTile(
                leading: const Icon(Icons.copyright_outlined),
                title: const Text('Licence'),
                subtitle: const Text(AppInfo.copyright),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => openLink(context, AppInfo.licenseUrl),
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Open-source licences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: AppInfo.name,
                  applicationVersion: version,
                  applicationLegalese: AppInfo.copyright,
                  applicationIcon: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Image.asset('asset/launchIcon.png', width: 12.w),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Made with ♥ by ${AppInfo.company}',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          SizedBox(height: .5.h),
          Text(
            AppInfo.copyright,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _copyVersion(BuildContext context, String version) async {
    await Clipboard.setData(ClipboardData(text: '${AppInfo.name} $version'));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Version copied')),
    );
  }

  void _showTranslationCredits(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _TranslationCredits(),
    );
  }
}

/// Credits every translation in the version catalogue, so newly published
/// versions are acknowledged without an app update. Falls back to the
/// installed versions when the catalogue can't be loaded.
class _TranslationCredits extends ConsumerWidget {
  const _TranslationCredits();

  static const _noLicense = 'All rights reserved by the rights holder.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(catalogueProvider).value?.catalogue.entries;
    final credits = entries != null && entries.isNotEmpty
        ? [
            for (final entry in entries)
              (
                title: '${entry.name} (${entry.abbreviation})',
                license: entry.license ?? _noLicense,
              ),
          ]
        : [
            for (final version in ref.watch(installedVersionsProvider))
              (title: version.versionName, license: _noLicense),
          ];

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 70.h),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(2.w, 2.h, 2.w, 3.h),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Bible translations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(height: 1.h),
          for (final credit in credits)
            ListTile(
              title: Text(credit.title),
              subtitle: Text(credit.license),
            ),
        ],
      ),
    );
  }
}

const _meteoconsLicense = '''MIT License

Copyright (c) 2020 Bas Milius

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.''';
