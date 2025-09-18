// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:provider/provider.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = Colors.teal; // Color por defecto

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    final colorValue = prefs.getInt('primaryColor') ?? Colors.teal.value;
    _primaryColor = Color(colorValue);
    notifyListeners();
  }

  void toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();

    // Llama a la lógica para otorgar la insignia cuando se cambia el tema
    // Para que funcione, el contexto (context) debe ser accesible.
    // Esto se hace en la pantalla que usa el provider.
    // Un ejemplo de cómo se llamaría:
    // context.read<InsigniaProvider>().otorgarInsignia('personalizador_1', context);
    // Nota: Esta llamada se hace mejor directamente en el widget (TemasConfiguracion).
  }

  void setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }
}