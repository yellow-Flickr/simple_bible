import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
    final version = ref.watch(appVersionProvider).valueOrNull;

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
            Text(
              'Version $version',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
            ),
          SizedBox(height: 1.5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'A simple, offline Bible for everyday reading. Read in English '
              'or Akuapem Twi, explore verses by topic, reflect daily and '
              'keep your own notes.',
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
              const ListTile(
                leading: Icon(Icons.menu_book_outlined),
                title: Text('King James Version'),
                subtitle: Text('Public domain.'),
              ),
              const ListTile(
                leading: Icon(Icons.menu_book_outlined),
                title: Text('Akuapem Twi Bible'),
                subtitle: Text(
                  'Included for personal reading. All rights remain with the '
                  'translation\'s copyright holder.',
                ),
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
            title: 'Made by',
            children: [
              for (final author in AppInfo.authors)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(author.name),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => openLink(context, author.url),
                ),
            ],
          ),
          SettingsSection(
            title: 'Legal',
            children: [
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Open-source licences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: AppInfo.name,
                  applicationVersion: version,
                  applicationIcon: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Image.asset('asset/launchIcon.png', width: 12.w),
                  ),
                ),
              ),
            ],
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
