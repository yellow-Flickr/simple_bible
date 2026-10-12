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
      primaryColorLight: Colors.black26,
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
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFD8B04A),
      onPrimary: Color(0xFF19181A),
      secondary: Color(0xFFFFD778),
      onSecondary: Color(0xFF19181A),
      surface: Color(0xFF1E1F23),
      onSurface: Color(0xFFEAE6DD),
      error: Color(0xFFCF6679),
      onError: Color(0xFF19181A),
    ),
    primarySwatch: Colors.blueGrey,
    primaryColor: const Color(0xFF1E1F23),
    primaryColorDark: const Color(0xFFD8B04A),
    primaryColorLight: const Color(0xFFEAE6DD),
    scaffoldBackgroundColor: const Color(0xFF121316),
    cardColor: const Color(0xFF26272C),
    dividerColor: Colors.white12,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1E1F23),
      foregroundColor: Color(0xFFEAE6DD),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      showUnselectedLabels: true,
      elevation: 0,
      backgroundColor: Color(0xFF1E1F23),
      selectedItemColor: Color(0xFFD8B04A),
      unselectedItemColor: Color(0xFFAAA8A2),
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.normal,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Color(0xFFEAE6DD),
        fontWeight: FontWeight.normal,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFFEAE6DD),
        fontSize: 20,
      ),
      bodySmall: TextStyle(
        color: Color(0xFFEAE6DD),
      ),
      labelMedium: TextStyle(
        color: Color(0xFFD8B04A),
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E1F23),
      modalBackgroundColor: Color(0xFF1E1F23),
    ),
  );
}
