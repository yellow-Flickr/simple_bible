import 'package:flutter/material.dart';

// Color primaryColor = Colors.amber;
// Color darkColor = const Color.fromARGB(255, 12, 12, 12);

class Themes {
/* light theme settings */
  static ThemeData lightTheme = ThemeData(
      primarySwatch: Colors.blueGrey,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 237, 218, 255),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          showUnselectedLabels: true,
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 237, 218, 255),
          // selectedIconTheme: IconThemeData(color: Colors.purple),
          // unselectedIconTheme: IconThemeData(color: Colors.black54),
          unselectedItemColor: Colors.black54,
          selectedItemColor: Colors.purple,
          selectedLabelStyle: TextStyle(color: Colors.purple),
          unselectedLabelStyle: TextStyle(color: Colors.black54)),
      primaryColor: Color(0xFFEDDAFF),
      primaryColorDark: Color(0xFF9C27B0),
      primaryColorLight: Color.fromARGB(255, 25, 24, 26),
      brightness: Brightness.light,
      cardColor: const Color.fromARGB(255, 237, 218, 255),
      textTheme: const TextTheme(
          bodyMedium:
              TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.black, fontSize: 20),
          bodySmall: TextStyle(color: Colors.black)),
      dividerColor: Colors.white12,
      scaffoldBackgroundColor: Colors.white);

  /* Dark theme settings */
  static ThemeData darkTheme = ThemeData(
      primarySwatch: Colors.blueGrey,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 25, 24, 26),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        showUnselectedLabels: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 25, 24, 26),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.amber,
      ),
      primaryColor: const Color.fromARGB(255, 25, 24, 26),
      primaryColorDark: Color(0xFFFFC107),
      primaryColorLight: Colors.white,
      brightness: Brightness.dark,
      cardColor: const Color.fromARGB(255, 12, 12, 12),
      textTheme: const TextTheme(
          bodyMedium:
              TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          bodySmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 20)),
      dividerColor: Colors.black12,
      scaffoldBackgroundColor: const Color.fromARGB(255, 12, 12, 12));
}
