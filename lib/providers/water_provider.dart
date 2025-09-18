// lib/providers/water_provider.dart

import 'package:flutter/material.dart';
import 'package:msa/models/agua.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WaterProvider with ChangeNotifier {
  late Box<Agua> _aguaBox;
  double _meta = 2500.0;

  WaterProvider() {
    _init();
  }

  Future<void> _init() async {
    _aguaBox = Hive.box<Agua>('aguaBox');
    await loadGoal();
    notifyListeners();
  }

  List<Agua> get registros => _aguaBox.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  double get meta => _meta;

  Future<void> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    _meta = prefs.getDouble('waterGoal') ?? 2500.0;
  }

  Future<void> saveGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('waterGoal', _meta);
  }

  double getIngestaPorFecha(DateTime fecha) {
    return _aguaBox.values
        .where((r) =>
            r.timestamp.day == fecha.day &&
            r.timestamp.month == fecha.month &&
            r.timestamp.year == fecha.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  List<Agua> getRegistrosPorFecha(DateTime fecha) {
    return _aguaBox.values
        .where((r) =>
            r.timestamp.day == fecha.day &&
            r.timestamp.month == fecha.month &&
            r.timestamp.year == fecha.year)
        .toList();
  }

  void addAgua(double cantidad, DateTime fecha) {
    final ahora = DateTime.now();
    final fechaCompleta = DateTime(fecha.year, fecha.month, fecha.day, ahora.hour, ahora.minute, ahora.second);
    final id = const Uuid().v4();
    final nuevoRegistro = Agua(
      id: id,
      amount: cantidad,
      timestamp: fechaCompleta,
    );
    _aguaBox.put(id, nuevoRegistro);
    notifyListeners();
  }

  void editarRegistro(String id, double nuevaCantidad) {
    final registro = _aguaBox.get(id);
    if (registro != null) {
      registro.amount = nuevaCantidad;
      registro.save();
      notifyListeners();
    }
  }

  void eliminarRegistro(String id) {
    _aguaBox.delete(id);
    notifyListeners();
  }

  void setMeta(double nuevaMeta) {
    _meta = nuevaMeta;
    saveGoal();
    notifyListeners();
  }

  // --- NUEVA FUNCIÓN AÑADIDA ---
  Map<DateTime, double> getIngestaUltimos7Dias() {
    final Map<DateTime, double> ingestaPorDia = {};
    final hoy = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final fecha = hoy.subtract(Duration(days: i));
      final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);
      
      ingestaPorDia[fechaSinHora] = getIngestaPorFecha(fechaSinHora);
    }
    return ingestaPorDia;
  }
}