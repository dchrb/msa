import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final String keyThemeMode = "theme_mode";
  final String keySeedColor = "seed_color";

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.blue;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  List<Color> get availableColors => _availableColors;

  ThemeProvider() {
    _loadFromPrefs();
  }

  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(keyThemeMode) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeModeIndex];
    final seedColorValue = prefs.getInt(keySeedColor) ?? _seedColor.toARGB32();
    _seedColor = Color(seedColorValue);
    notifyListeners();
  }

  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(keyThemeMode, _themeMode.index);
    prefs.setInt(keySeedColor, _seedColor.toARGB32());
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _saveToPrefs();
    notifyListeners();
  }

  void setSeedColor(Color color) {
    if (color == _seedColor) return;
    _seedColor = color;
    _saveToPrefs();
    notifyListeners();
  }
}
