import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureInitializationProvider, scriptureServiceProvider;
import 'package:simple_bible/user_space/data/user_space_repository_provider.dart';
import 'package:simple_bible/user_space/domain/user_space.dart';

class UserSpaceService extends Notifier<UserSpace> {
  @override
  UserSpace build() {
    final repository = ref.read(userSpaceRepositoryProvider);
    final userSpace = repository.getUserSpace();
    if (userSpace == null) {
      final guest = UserSpace.guest();
      // Save the guest user (fire and forget)
      // ignore: unawaited_futures
      repository.saveUserSpace(guest);
      return guest;
    }
    return userSpace;
  }

  /// Sets the Bible version used across the app and persists it.
  Future<void> setPreferredTranslation(int versionId) async {
    if (state.preferredTranslation == versionId) return;
    state = state.copyWith(preferredTranslation: versionId);
    await ref.read(userSpaceRepositoryProvider).saveUserSpace(state);
  }

  /// Sets the app theme and persists it.
  Future<void> setThemeMode(ThemeMode mode) async {
    final theme = mode.index;
    if (state.theme == theme) return;
    state = state.copyWith(theme: theme);
    await ref.read(userSpaceRepositoryProvider).saveUserSpace(state);
  }
}

final userSpaceProvider =
    NotifierProvider<UserSpaceService, UserSpace>(() => UserSpaceService());

/// The app-wide Bible version id. Falls back to the first installed version
/// when the stored preference is no longer available.
final preferredVersionIdProvider = Provider<int>((ref) {
  final preferred = ref.watch(
    userSpaceProvider.select((userSpace) => userSpace.preferredTranslation),
  );
  // Recompute once the bundled versions have been stored at startup.
  ref.watch(scriptureInitializationProvider);
  final versions = ref.watch(scriptureServiceProvider).getVersions();
  return resolvePreferredVersionId(preferred, versions);
});

int resolvePreferredVersionId(int preferred, List<Versions> versions) {
  if (versions.isEmpty || versions.any((v) => v.id == preferred)) {
    return preferred;
  }
  return versions.first.id;
}

/// The app theme. [UserSpace.theme] stores a [ThemeMode] index
/// (0 system, 1 light, 2 dark); anything else means system.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final theme = ref.watch(userSpaceProvider.select((u) => u.theme));
  return ThemeMode.values.elementAtOrNull(theme ?? 0) ?? ThemeMode.system;
});
