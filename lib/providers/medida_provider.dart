import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

import 'package:msa/models/medida.dart';
import 'package:msa/providers/sync_provider.dart';

class MedidaProvider with ChangeNotifier {
  SyncProvider? _syncProvider;
  late Box<Medida> _medidasBox;
  bool _isInitialized = false;
  final Uuid _uuid = const Uuid();

  bool get isInitialized => _isInitialized;
  List<Medida> get registros => _medidasBox.values.toList()..sort((a, b) => b.fecha.compareTo(a.fecha));

  MedidaProvider() {
    _init();
  }

  Future<void> _init() async {
    _medidasBox = await Hive.openBox<Medida>('medidasBox');
    _isInitialized = true;
    _medidasBox.listenable().addListener(notifyListeners);
    notifyListeners();
  }

  void updateSyncProvider(SyncProvider? syncProvider) {
    _syncProvider = syncProvider;
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<void> agregarMedidas(Map<String, double> medidas, DateTime fecha) async {
    final fechaNormalizada = _normalizeDate(fecha);

    for (var entry in medidas.entries) {
      final tipo = entry.key;
      final valor = entry.value;

      // Busca si ya existe una medida de este tipo para esta fecha.
      final medidaExistente = _medidasBox.values.firstWhereOrNull(
        (m) => m.tipo == tipo && _normalizeDate(m.fecha) == fechaNormalizada
      );

      if (medidaExistente != null) {
        // Si existe, actualízala.
        medidaExistente.valor = valor;
        await _medidasBox.put(medidaExistente.key, medidaExistente);
        _syncProvider?.syncDocumentToFirestore('medidas', medidaExistente.key as String, medidaExistente.toJson());
      } else {
        // Si no existe, crea una nueva.
        final nuevaMedida = Medida(
          id: _uuid.v4(),
          fecha: fechaNormalizada,
          tipo: tipo,
          valor: valor,
        );
        await _medidasBox.put(nuevaMedida.id, nuevaMedida);
        _syncProvider?.syncDocumentToFirestore('medidas', nuevaMedida.id, nuevaMedida.toJson());
      }
    }
  }

  Future<void> editarMedida(Medida medida) async {
    await _medidasBox.put(medida.key, medida);
    _syncProvider?.syncDocumentToFirestore('medidas', medida.key as String, medida.toJson());
  }

  Future<void> eliminarMedida(dynamic key) async {
    await _medidasBox.delete(key);
    _syncProvider?.deleteDocumentFromFirestore('medidas', key as String);
  }

  Medida? getUltimaMedida() {
    return registros.firstOrNull;
  }

  Medida? getPenultimaMedida() {
    final regs = registros;
    return regs.length > 1 ? regs[1] : null;
  }

  Medida? getUltimaMedidaPorTipo(String tipo) {
    return registros.firstWhereOrNull((m) => m.tipo == tipo);
  }

  Future<void> replaceAll(List<Medida> medidas) async {
    await _medidasBox.clear();
    final Map<dynamic, Medida> medidasMap = { for (var m in medidas) m.id : m };
    await _medidasBox.putAll(medidasMap);
  }
}
