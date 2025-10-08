import 'package:flutter/material.dart';

// Color primaryColor = Colors.amber;
// Color darkColor = const Color.fromARGB(255, 12, 12, 12);

class Themes {
/* light theme settings */
  static ThemeData lightTheme = ThemeData(
      primarySwatch: Colors.blueGrey,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFFfff0cc),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          showUnselectedLabels: true,
          elevation: 0,
          backgroundColor: Color(0xFFfff0cc),
          // selectedIconTheme: IconThemeData(color: const Color(0xFFd8b04a)),
          // unselectedIconTheme: IconThemeData(color: Colors.black54),
          unselectedItemColor: Colors.black54,
          selectedItemColor: Color(0xFFd8b04a),
          selectedLabelStyle: TextStyle(color: Color(0xFFd8b04a)),
          unselectedLabelStyle: TextStyle(color: Colors.black54)),
      primaryColor: const Color(0xFFfff0cc),
      primaryColorDark: const Color(0xFFd8b04a),
      primaryColorLight: const Color.fromARGB(255, 25, 24, 26),
      brightness: Brightness.light,
      cardColor: const Color(0xFFfff0cc),
      textTheme: const TextTheme(
          bodyMedium:
              TextStyle(color: Color(0xFFd8b04a), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.black, fontSize: 20),
          bodySmall: TextStyle(color: Colors.black)),
      dividerColor: Colors.white12,
      bottomSheetTheme:
          BottomSheetThemeData(modalBackgroundColor: Color(0xFFfff0cc)),
      scaffoldBackgroundColor: Colors.white);

/* light theme settings */
  static ThemeData greenTheme = ThemeData(
      primarySwatch: Colors.blueGrey,
      appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          showUnselectedLabels: true,
          elevation: 0,
          backgroundColor: Color(0xFF1B5E20),
          // selectedIconTheme: IconThemeData(color: Colors.purple),
          // unselectedIconTheme: IconThemeData(color: Colors.black54),
          unselectedItemColor: Colors.white54,
          selectedItemColor: Color.fromARGB(255, 255, 255, 255),
          selectedLabelStyle: TextStyle(color: Colors.purple),
          unselectedLabelStyle: TextStyle(color: Colors.white)),
      primaryColor: const Color(0xFFEDDAFF),
      primaryColorDark: const Color(0xFF9C27B0),
      primaryColorLight: const Color.fromARGB(255, 255, 255, 255),
      brightness: Brightness.light,
      cardColor: const Color(0xFF1B5E20),
      bottomSheetTheme:
          BottomSheetThemeData(modalBackgroundColor: Color(0xFF1B5E20)),
      textTheme: const TextTheme(
          bodyMedium:
              TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 20),
          bodySmall: TextStyle(color: Colors.white)),
      dividerColor: Colors.white12,
      scaffoldBackgroundColor: Color(0xFF1B5E20));

  /* Dark theme settings */
  static ThemeData darkTheme = ThemeData(
      primarySwatch: Colors.blueGrey,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF19181A),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        showUnselectedLabels: true,
        elevation: 0,
        backgroundColor: Color(0xFF19181A),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.amber,
      ),
      primaryColor: const Color.fromARGB(255, 25, 24, 26),
      primaryColorDark: const Color(0xFFFFC107),
      primaryColorLight: Colors.white,
      brightness: Brightness.dark,
      cardColor: const Color(0xFF0C0C0C),
      textTheme: const TextTheme(
          bodyMedium:
              TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          bodySmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 20)),
      dividerColor: Colors.black12,
      bottomSheetTheme:
          BottomSheetThemeData(modalBackgroundColor: Color(0xFF19181A)),
      scaffoldBackgroundColor: const Color.fromARGB(255, 12, 12, 12));
}
