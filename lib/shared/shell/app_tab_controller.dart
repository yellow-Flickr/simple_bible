import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTab { home, topics, notes, profile }

/// The selected bottom navigation tab. Screens can switch tabs by setting it.
final appTabProvider = StateProvider<AppTab>((ref) => AppTab.home);
