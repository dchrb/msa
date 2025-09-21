import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:msa/models/agua.dart';
import 'package:msa/providers/sync_provider.dart';

class WaterProvider with ChangeNotifier {
  SyncProvider? _syncProvider;
  late Box<Agua> _aguaBox;
  double _meta = 2500.0;
  bool _isInitialized = false;

  WaterProvider() {
    _init();
  }

  void updateSyncProvider(SyncProvider? syncProvider) {
    _syncProvider = syncProvider;
  }

  Future<void> _init() async {
    _aguaBox = Hive.box<Agua>('agua');
    await _loadGoal();
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;
  List<Agua> get registros => _aguaBox.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  
  // Getters para la pantalla de inicio
  double get metaDiaria => _meta; // <-- AÑADIDO para consistencia
  double get consumoTotalHoy { // <-- AÑADIDO
    if (!_isInitialized) return 0.0;
    return getIngestaPorFecha(DateTime.now());
  }

  Future<void> _loadGoal() async {
    final box = await Hive.openBox('water_goal');
    _meta = box.get('goal', defaultValue: 2500.0);
  }

  Future<void> _saveGoal() async {
    final box = await Hive.openBox('water_goal');
    await box.put('goal', _meta);
  }

  double getIngestaPorFecha(DateTime fecha) {
    final inicioDia = DateTime(fecha.year, fecha.month, fecha.day);
    final finDia = inicioDia.add(const Duration(days: 1));

    return _aguaBox.values
        .where((r) =>
            !r.timestamp.isBefore(inicioDia) && r.timestamp.isBefore(finDia))
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

  Future<void> addAgua(double cantidad, DateTime fecha) async {
    final ahora = DateTime.now();
    final fechaCompleta = DateTime(fecha.year, fecha.month, fecha.day, ahora.hour, ahora.minute, ahora.second);
    final id = const Uuid().v4();
    final nuevoRegistro = Agua(
      id: id,
      amount: cantidad,
      timestamp: fechaCompleta,
    );
    await _aguaBox.put(id, nuevoRegistro);
    await _syncProvider?.syncDocumentToFirestore('agua', id, nuevoRegistro.toJson());
    notifyListeners();
  }

  Future<void> updateAgua(Agua registro, double nuevaCantidad) async {
    final registroActualizado = registro.copyWith(amount: nuevaCantidad);
    await _aguaBox.put(registro.id, registroActualizado);
    await _syncProvider?.syncDocumentToFirestore('agua', registro.id, registroActualizado.toJson());
    notifyListeners();
  }

  Future<void> eliminarRegistro(String id) async {
    await _aguaBox.delete(id);
    await _syncProvider?.deleteDocumentFromFirestore('agua', id);
    notifyListeners();
  }

  Future<void> setMeta(double nuevaMeta) async {
    _meta = nuevaMeta;
    await _saveGoal();
    notifyListeners();
  }

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

  Future<void> replaceAllAgua(List<Agua> registros) async {
    await _aguaBox.clear();
    for (var registro in registros) {
      await _aguaBox.put(registro.id, registro);
    }
    notifyListeners();
  }
}
