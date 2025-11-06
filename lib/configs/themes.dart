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
      primaryColorLight: Colors.grey.shade700,
      brightness: Brightness.light,
      cardColor: const Color(0xFFfff0cc),
      textTheme: const TextTheme(
          bodyMedium:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          labelMedium: TextStyle(
              color: Color.fromARGB(255, 148, 9, 9),
              fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.black, fontSize: 20),
          bodySmall: TextStyle(color: Colors.black)),
      dividerColor: Colors.black12,
      bottomSheetTheme:
          BottomSheetThemeData(backgroundColor: Color(0xFFfff0cc)),

      // sliderTheme: SliderThemeData(),
      scaffoldBackgroundColor: Colors.white);

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
          labelMedium:
              TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          bodySmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 20)),
      dividerColor: Colors.black12,
      bottomSheetTheme:
          BottomSheetThemeData(modalBackgroundColor: Color(0xFF19181A)),
      scaffoldBackgroundColor: const Color.fromARGB(255, 12, 12, 12));
}
