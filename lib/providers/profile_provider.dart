// lib/providers/profile_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Sexo { masculino, femenino }
enum NivelActividad {
  sedentario, // poco o nada de ejercicio
  ligero,     // 1-3 días/semana
  moderado,   // 3-5 días/semana
  activo      // 6-7 días/semana
}

class ProfileProvider with ChangeNotifier {
  String? _nombre;
  int? _edad;
  double? _altura;
  double? _peso;
  Sexo? _sexo;
  NivelActividad? _nivelActividad;
  String? _imagePath;

  // --- 1. AÑADIMOS EL ESTADO DE CARGA ---
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  
  // Getters para todos los campos
  String? get nombre => _nombre;
  int? get edad => _edad;
  double? get altura => _altura;
  double? get peso => _peso;
  Sexo? get sexo => _sexo;
  NivelActividad? get nivelActividad => _nivelActividad;
  String? get imagePath => _imagePath;

  bool get perfilCreado => _nombre != null && _nombre!.isNotEmpty;

  ProfileProvider() {
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    _nombre = prefs.getString('nombre');
    _edad = prefs.getInt('edad');
    _altura = prefs.getDouble('altura');
    _peso = prefs.getDouble('peso');
    _imagePath = prefs.getString('imagePath');
    int? sexoIndex = prefs.getInt('sexo');
    if (sexoIndex != null) _sexo = Sexo.values[sexoIndex];
    int? actividadIndex = prefs.getInt('nivelActividad');
    if (actividadIndex != null) _nivelActividad = NivelActividad.values[actividadIndex];
    
    // --- 2. AVISAMOS QUE LA CARGA HA TERMINADO ---
    _isLoading = false;
    notifyListeners();
  }

  Future<void> guardarPerfil({
    required String nombre,
    required int edad,
    required double altura,
    required double peso,
    required Sexo sexo,
    required NivelActividad nivelActividad,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre', nombre);
    await prefs.setInt('edad', edad);
    await prefs.setDouble('altura', altura);
    await prefs.setDouble('peso', peso);
    await prefs.setInt('sexo', sexo.index);
    await prefs.setInt('nivelActividad', nivelActividad.index);
    if (imagePath != null) {
      await prefs.setString('imagePath', imagePath);
    }
    await cargarPerfil();
  }
  
  Future<void> actualizarPeso(double nuevoPeso) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('peso', nuevoPeso);
      _peso = nuevoPeso;
      notifyListeners();
  }

  double get bmr {
    if (_peso == null || _altura == null || _edad == null || _sexo == null) return 0;
    if (_sexo == Sexo.masculino) {
      return (10 * _peso!) + (6.25 * _altura!) - (5 * _edad!) + 5;
    } else {
      return (10 * _peso!) + (6.25 * _altura!) - (5 * _edad!) - 161;
    }
  }

  double get caloriasRecomendadas {
    if (_nivelActividad == null) return bmr;
    double multiplicador = 1.2;
    switch (_nivelActividad!) {
      case NivelActividad.ligero: multiplicador = 1.375; break;
      case NivelActividad.moderado: multiplicador = 1.55; break;
      case NivelActividad.activo: multiplicador = 1.725; break;
      case NivelActividad.sedentario:
      default: multiplicador = 1.2;
    }
    return bmr * multiplicador;
  }
}