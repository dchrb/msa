// lib/providers/recordatorio_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:msa/models/recordatorio.dart';
import 'package:msa/providers/sync_provider.dart';
import 'package:msa/services/notification_service.dart';

class RecordatorioProvider with ChangeNotifier {
  SyncProvider? _syncProvider;
  late Box<Recordatorio> _recordatoriosBox;
  bool _isInitialized = false;

  RecordatorioProvider() {
    _init();
  }

  void updateSyncProvider(SyncProvider? syncProvider) {
    _syncProvider = syncProvider;
  }

  Future<void> _init() async {
    _recordatoriosBox = Hive.box<Recordatorio>('recordatoriosBox');
    _isInitialized = true;
    notifyListeners();
    // Al inicializar, asegurarse que las notificaciones estén sincronizadas con el estado de Hive
    await _rescheduleAllNotifications();
  }

  bool get isInitialized => _isInitialized;
  List<Recordatorio> get recordatorios => _recordatoriosBox.values.toList();

  Future<void> anadirRecordatorio(TimeOfDay hora, String mensaje) async {
    final nuevo = Recordatorio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hora: hora.hour,
      minuto: hora.minute,
      mensaje: mensaje,
      activado: true,
    );
    await _recordatoriosBox.put(nuevo.id, nuevo);
    await _syncProvider?.syncDocumentToFirestore('recordatorios', nuevo.id, nuevo.toJson());
    // Usamos el método corregido y renombrado
    await NotificationService().programarRecordatorioDiario(nuevo);
    notifyListeners();
  }

  Future<void> eliminarRecordatorio(String id) async {
    final recordatorio = _recordatoriosBox.get(id);
    if(recordatorio != null) {
      // Usamos el método corregido y renombrado
       await NotificationService().cancelarRecordatorio(recordatorio.id);
    }
    
    await _recordatoriosBox.delete(id);
    await _syncProvider?.deleteDocumentFromFirestore('recordatorios', id);
    notifyListeners();
  }

  Future<void> actualizarRecordatorio(Recordatorio recordatorio) async {
    await _recordatoriosBox.put(recordatorio.id, recordatorio);
    await _syncProvider?.syncDocumentToFirestore('recordatorios', recordatorio.id, recordatorio.toJson());
    
    if (recordatorio.activado) {
      // Usamos el método corregido y renombrado
      await NotificationService().programarRecordatorioDiario(recordatorio);
    } else {
      // Usamos el método corregido y renombrado
      await NotificationService().cancelarRecordatorio(recordatorio.id);
    }
    notifyListeners();
  }

  Future<void> replaceAllRecordatorios(List<Recordatorio> remoteRecordatorios) async {
    await _recordatoriosBox.clear();
    for (var recordatorio in remoteRecordatorios) {
      await _recordatoriosBox.put(recordatorio.id, recordatorio);
    }
    // Al reemplazar todos los datos, reprogramar todas las notificaciones
    await _rescheduleAllNotifications();
    notifyListeners();
  }

  Future<void> _rescheduleAllNotifications() async {
    final notificationService = NotificationService();
    // Usamos el método corregido y renombrado
    await notificationService.cancelarTodosLosRecordatorios(); 
    for (final recordatorio in _recordatoriosBox.values) {
      if (recordatorio.activado) {
        // Usamos el método corregido y renombrado
        await notificationService.programarRecordatorioDiario(recordatorio);
      }
    }
  }
}
