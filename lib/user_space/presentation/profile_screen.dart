import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/bible_reader/presentation/version_picker.dart';
import 'package:simple_bible/favorites/presentation/favorites_view.dart';
import 'package:simple_bible/history/presentation/history_screen.dart';
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      joined == null
                          ? 'Guest account'
                          : 'Guest account · Joined '
                              '${DateFormat('MMMM yyyy').format(joined)}',
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _Section(
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
          _Section(
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
          const _Section(
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
          _Section(
            title: 'Your activity',
            children: [
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Favourite verses'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesView()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Reading history'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                for (final (index, child) in children.indexed) ...[
                  if (index > 0) Divider(height: 1, color: theme.dividerColor),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
