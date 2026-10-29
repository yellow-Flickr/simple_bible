import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart';
import 'package:simple_bible/favorites/application/favorites_service.dart';
import 'package:simple_bible/favorites/data/local_favorites_repository.dart';
import 'package:simple_bible/favorites/presentation/favorites_controller.dart';
import 'package:simple_bible/history/application/history_service.dart';
import 'package:simple_bible/history/data/local_history_repository.dart';
import 'package:simple_bible/history/presentation/history_controller.dart';
import 'package:simple_bible/notes/application/notes_service.dart';
import 'package:simple_bible/notes/data/notes_repository.dart';
import 'package:simple_bible/notes/presentation/notes_controller.dart';
import 'package:simple_bible/shared/configs/objectbox.dart';
import 'package:simple_bible/launcher.dart';
import 'package:simple_bible/shared/configs/themes.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final objectBox = await ObjectBox.create();
  runApp(ProviderScope(
    overrides: [
      // Override the unimplemented provider with the value gotten from the plugin
      objectBoxProvider.overrideWithValue(objectBox),
      notesServiceProvider.overrideWithValue(
        NotesService(LocalNotesRepository(objectBox.objStore)),
      ),
      favoritesServiceProvider.overrideWithValue(
        FavoritesService(LocalFavoritesRepository(objectBox.objStore)),
      ),
      historyServiceProvider.overrideWithValue(
        HistoryService(LocalHistoryRepository(objectBox.objStore)),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(scriptureInitializationProvider);
    final themeMode = ref.watch(themeModeProvider);

    return ResponsiveSizer(builder:
        (BuildContext context, Orientation orientation, ScreenType deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        // title: 'Flutter Demo',
        darkTheme: Themes.darkTheme, // standard dark theme
        theme: Themes.lightTheme,
        themeMode: themeMode,
        home: const Launcher(),
      );
    });
  }
}
