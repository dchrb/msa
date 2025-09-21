import 'package:flutter/material.dart';
import 'package:msa/models/profile.dart';

class ProfileProvider with ChangeNotifier {
  Profile? _profile;
  bool _isLoading = true;

  // Getters
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get perfilCreado => _profile != null && _profile!.name.isNotEmpty;

  void setInitialProfile(Profile? profile) {
    _profile = profile;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> guardarPerfil({
    required String nombre,
    int? edad,
    double? altura,
    double? peso,
    Sexo? sexo,
    NivelActividad? nivelActividad,
    String? imagePath,
  }) async {
    // La meta de peso y calorías ahora se guardan por separado
    if (_profile == null) {
      if (edad != null && altura != null && peso != null && sexo != null && nivelActividad != null) {
        _profile = Profile(
          name: nombre, age: edad, height: altura, currentWeight: peso,
          sex: sexo, activityLevel: nivelActividad, imagePath: imagePath,
        );
      } else { return; }
    } else {
      _profile = _profile!.copyWith(
        name: nombre, age: edad, height: altura, currentWeight: peso,
        sex: sexo, activityLevel: nivelActividad, imagePath: imagePath ?? _profile!.imagePath,
      );
    }
    notifyListeners();
  }

  // ¡NUEVO! Método específico para guardar metas
  Future<void> guardarMetas({double? metaPeso, double? metaCalorias}) async {
    if (_profile != null) {
      _profile = _profile!.copyWith(
        weightGoal: metaPeso,
        calorieGoal: metaCalorias,
      );
      notifyListeners();
    }
  }

  Future<void> actualizarPesoActual(double nuevoPeso) async {
    if (_profile != null) {
      _profile = _profile!.copyWith(currentWeight: nuevoPeso);
      notifyListeners();
    }
  }

  void setProfile(Profile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  void loadProfileFromMap(Map<String, dynamic> map) {
    _profile = Profile.fromJson(map);
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }

  double get bmr {
    if (_profile == null) return 0;
    if (_profile!.sex == Sexo.masculino) {
      return (10 * _profile!.currentWeight) + (6.25 * _profile!.height) - (5 * _profile!.age) + 5;
    } else {
      return (10 * _profile!.currentWeight) + (6.25 * _profile!.height) - (5 * _profile!.age) - 161;
    }
  }

  double calculateCaloriasRecomendadas() {
    if (_profile == null) return 2000;
    double multiplicador;
    switch (_profile!.activityLevel) {
      case NivelActividad.sedentario: multiplicador = 1.2; break;
      case NivelActividad.ligero: multiplicador = 1.375; break;
      case NivelActividad.moderado: multiplicador = 1.55; break;
      case NivelActividad.activo: multiplicador = 1.725; break;
      case NivelActividad.muyActivo: multiplicador = 1.9; break;
    }
    return bmr * multiplicador;
  }

  double? get imc {
    if (_profile == null || _profile!.height == 0) return null;
    final alturaEnMetros = _profile!.height / 100.0;
    return _profile!.currentWeight / (alturaEnMetros * alturaEnMetros);
  }

  String get imcInterpretation {
    final val = imc;
    if (val == null) return "Datos incompletos";
    if (val < 18.5) return "Bajo peso";
    if (val < 25) return "Peso saludable";
    if (val < 30) return "Sobrepeso";
    return "Obesidad";
  }
}
