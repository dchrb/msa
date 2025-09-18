import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:msa/models/recordatorio.dart';
import 'package:msa/services/notification_service.dart';

class RecordatorioProvider with ChangeNotifier {
  final Box<Recordatorio> _box = Hive.box<Recordatorio>('recordatoriosBox');

  List<Recordatorio> get recordatorios => _box.values.toList();

  void anadirRecordatorio(TimeOfDay hora, String mensaje) {
    final nuevo = Recordatorio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hora: hora.hour,
      minuto: hora.minute,
      mensaje: mensaje,
      activado: true,
    );
    _box.put(nuevo.id, nuevo);
    NotificationService().programarRecordatorio(nuevo);
    notifyListeners();
  }

  void eliminarRecordatorio(String id) {
    NotificationService().cancelarRecordatorio(id.hashCode);
    _box.delete(id);
    notifyListeners();
  }

  void actualizarRecordatorio(Recordatorio recordatorio) {
    _box.put(recordatorio.id, recordatorio);
    if (recordatorio.activado) {
      NotificationService().programarRecordatorio(recordatorio);
    } else {
      NotificationService().cancelarRecordatorio(recordatorio.id.hashCode);
    }
    notifyListeners();
  }
}