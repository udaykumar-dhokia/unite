import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode;
  Color _accentColor;

  ThemeNotifier(this._isDarkMode, this._accentColor);

  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;

  void updateThemeMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  void updateAccentColor(Color newColor) {
    _accentColor = newColor;
    notifyListeners();
  }
}
