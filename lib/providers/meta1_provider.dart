// lib/providers/meta1_provider.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Meta1Provider extends ChangeNotifier {
  static const String _boxName = "metaBox";

  int _caloriasBase = 2000;
  int _deficit = 500;
  // --- 1. AÑADIMOS EL ESTADO DE CARGA ---
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Meta1Provider() {
    _cargarDesdeHive();
  }

  int get caloriasBase => _caloriasBase;
  int get deficit => _deficit;
  int get metaCalorias => (_caloriasBase - _deficit).clamp(0, 10000);

  void setCaloriasBase(int value) {
    _caloriasBase = value;
    _guardarEnHive();
    notifyListeners();
  }

  void setDeficit(int value) {
    _deficit = value;
    _guardarEnHive();
    notifyListeners();
  }

  Future<void> _guardarEnHive() async {
    final box = await Hive.openBox(_boxName);
    await box.put('caloriasBase', _caloriasBase);
    await box.put('deficit', _deficit);
  }

  Future<void> _cargarDesdeHive() async {
    final box = await Hive.openBox(_boxName);
    _caloriasBase = box.get('caloriasBase', defaultValue: 2000);
    _deficit = box.get('deficit', defaultValue: 500);
    
    // --- 2. AVISAMOS QUE LA CARGA HA TERMINADO ---
    _isLoading = false;
    notifyListeners();
  }
}