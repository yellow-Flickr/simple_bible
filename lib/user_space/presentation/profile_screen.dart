import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/bible_reader/presentation/version_picker.dart';
import 'package:simple_bible/user_space/legal_content.dart';
import 'package:simple_bible/user_space/presentation/about/about_screen.dart';
import 'package:simple_bible/user_space/presentation/about/app_actions.dart';
import 'package:simple_bible/user_space/presentation/about/legal_screen.dart';
import 'package:simple_bible/shared/widgets/settings_section.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userSpace = ref.watch(userSpaceProvider);
    final themeMode = ref.watch(themeModeProvider);
    final versionId = ref.watch(preferredVersionIdProvider);
    final versionName = ref
            .watch(scriptureServiceProvider)
            .getVersions()
            .where((version) => version.id == versionId)
            .firstOrNull
            ?.versionName ??
        'Not installed';

    final name = userSpace.username ?? 'Guest';
    final joined = userSpace.createdAt == null
        ? null
        : DateTime.fromMicrosecondsSinceEpoch(userSpace.createdAt!);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
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
          Row(
            children: [
              CircleAvatar(
                radius: 8.w,
                backgroundColor: theme.primaryColor,
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColorDark,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      joined == null
                          ? 'Guest account'
                          : 'Guest account · Joined '
                              '${DateFormat('MMMM yyyy').format(joined)}',
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SettingsSection(
            title: 'Reading',
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Bible version'),
                subtitle: Text(versionName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showVersionPicker(context, ref),
              ),
              const ListTile(
                enabled: false,
                leading: Icon(Icons.download_outlined),
                title: Text('Download more versions'),
                subtitle: Text('Coming soon'),
              ),
            ],
          ),
          SettingsSection(
            title: 'Appearance',
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeMode},
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: theme.primaryColorDark,
                      selectedForegroundColor: Colors.black,
                    ),
                    onSelectionChanged: (selection) => ref
                        .read(userSpaceProvider.notifier)
                        .setThemeMode(selection.single),
                  ),
                ),
              ),
            ],
          ),
          const SettingsSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                value: false,
                onChanged: null,
                secondary: Icon(Icons.wb_sunny_outlined),
                title: Text('Verse of the Day'),
                subtitle: Text('Coming soon'),
              ),
              SwitchListTile(
                value: false,
                onChanged: null,
                secondary: Icon(Icons.self_improvement_outlined),
                title: Text('Daily reflection'),
                subtitle: Text('Coming soon'),
              ),
            ],
          ),
          SettingsSection(
            title: 'Support',
            children: [
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share the app'),
                onTap: () => shareApp(context),
              ),
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Rate & review'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => rateApp(context),
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Send feedback'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => sendFeedback(context, ref),
              ),
            ],
          ),
          SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Simple Bible'),
                subtitle: const Text('Acknowledgements and licences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(context, const AboutScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(
                  context,
                  const LegalScreen(
                    title: 'Privacy policy',
                    sections: privacyPolicy,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: const Text('Terms of use'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(
                  context,
                  const LegalScreen(
                      title: 'Terms of use', sections: termsOfUse),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
