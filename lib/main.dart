import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_bible/DAO/LocalState.dart';
import 'package:simple_bible/launcher.dart';
import 'package:simple_bible/themes.dart';

Future<void> main() async {
  runApp(ChangeNotifierProvider(
    create: ((context) => LocalState()),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      darkTheme: Themes.darkTheme, // standard dark theme
      theme: Themes.lightTheme,
      themeMode: ThemeMode.system,
      home: const Launcher(),
    );
  }
}
