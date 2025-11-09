import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/application/scripture_service.dart';
import 'package:simple_bible/configs/objectbox.dart';
import 'package:simple_bible/launcher.dart';
import 'package:simple_bible/configs/themes.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final objectBox = await ObjectBox.create();
  runApp(ProviderScope(
    overrides: [
      // Override the unimplemented provider with the value gotten from the plugin
      objectBoxProvider.overrideWithValue(objectBox),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scriptureService = ref.watch(scriptureServiceProvider);
    final userSpace = ref.watch(userSpaceProvider);

    return ResponsiveSizer(builder:
        (BuildContext context, Orientation orientation, ScreenType deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        darkTheme: Themes.darkTheme, // standard dark theme
        theme: Themes.lightTheme,
        themeMode: ThemeMode.system,
        home: const Launcher(),
      );
    });
  }
}
