import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';

  ThemeProvider(this._prefs);

  ThemeMode get themeMode {
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme == 'dark') return ThemeMode.dark;
    if (savedTheme == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  bool get isDarkMode {
    return themeMode == ThemeMode.dark;
  }

  void toggleTheme(bool isDark) {
    _prefs.setString(_themeKey, isDark ? 'dark' : 'light');
    notifyListeners();
  }

  void setSystemTheme() {
    _prefs.remove(_themeKey);
    notifyListeners();
  }
}
