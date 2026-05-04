import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appThemeStateNotifier = ChangeNotifierProvider(
  (ref) => AppThemeStateNotifier(),
);

class AppThemeStateNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  final ThemeMode _systemMode = ThemeMode.system;

  ThemeMode get systemMode => _systemMode;
  bool get isDarkMode => _isDarkMode;
  
  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

}
