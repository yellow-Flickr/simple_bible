import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/home/presentation/home.dart';
import 'package:simple_bible/notes/presentation/note_list.dart';
import 'package:simple_bible/shared/shell/app_tab_controller.dart';
import 'package:simple_bible/topics/presentation/topic_catalog_screen.dart';
import 'package:simple_bible/user_space/presentation/profile_screen.dart';

/// Hosts the main tabs behind a bottom navigation bar. Each tab has its own
/// navigator, so screens opened from a tab keep the bar and the tab's back
/// stack survives switching tabs. Full-screen routes such as the reader are
/// pushed on the root navigator instead (see `openScripture`).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _navigatorKeys = {
    for (final tab in AppTab.values) tab: GlobalKey<NavigatorState>(),
  };

  Widget _rootScreen(AppTab tab) => switch (tab) {
        AppTab.home => const Home(),
        AppTab.topics => const TopicCatalogScreen(),
        AppTab.notes => const NoteList(),
        AppTab.profile => const ProfileScreen(),
      };

  void _onTabTapped(AppTab tab) {
    final current = ref.read(appTabProvider);
    if (tab == current) {
      // Tapping the current tab returns to its first screen.
      _navigatorKeys[tab]!.currentState?.popUntil((route) => route.isFirst);
      return;
    }
    ref.read(appTabProvider.notifier).state = tab;
  }

  Future<void> _onBack() async {
    final current = ref.read(appTabProvider);
    final navigator = _navigatorKeys[current]!.currentState;
    if (navigator != null && await navigator.maybePop()) return;
    if (current != AppTab.home) {
      ref.read(appTabProvider.notifier).state = AppTab.home;
      return;
    }
    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(appTabProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        body: IndexedStack(
          index: current.index,
          children: [
            for (final tab in AppTab.values)
              Navigator(
                key: _navigatorKeys[tab],
                onGenerateRoute: (settings) => MaterialPageRoute(
                  settings: settings,
                  builder: (context) => _rootScreen(tab),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          // Fixed so the theme's background colour applies with 4 items.
          type: BottomNavigationBarType.fixed,
          currentIndex: current.index,
          onTap: (index) => _onTabTapped(AppTab.values[index]),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined),
              activeIcon: Icon(Icons.auto_stories),
              label: 'Topics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sticky_note_2_outlined),
              activeIcon: Icon(Icons.sticky_note_2),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
