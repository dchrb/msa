import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:msa/models/models.dart';
import 'package:msa/providers/sync_provider.dart';
import 'package:uuid/uuid.dart';

class FoodProvider with ChangeNotifier {
  SyncProvider? _syncProvider;
  late Box<Plato> _platosBox;
  late Box<Alimento> _alimentosBox;

  final _uuid = const Uuid();
  bool _isInitialized = false;

  FoodProvider() {
    _init();
  }

  void updateSyncProvider(SyncProvider? syncProvider) {
    _syncProvider = syncProvider;
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen('platos')) {
      _platosBox = await Hive.openBox<Plato>('platos');
    } else {
      _platosBox = Hive.box<Plato>('platos');
    }
    if (!Hive.isBoxOpen('alimentos')) {
      _alimentosBox = await Hive.openBox<Alimento>('alimentos');
    } else {
      _alimentosBox = Hive.box<Alimento>('alimentos');
    }
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;

  // Getter para todos los platos (para el SyncProvider)
  List<Plato> get allPlatos => _isInitialized ? _platosBox.values.toList() : [];

  List<Plato> getPlatosPorFecha(DateTime fecha) {
    if (!_isInitialized) return [];
    final fechaNormalizada = _normalizeDate(fecha);
    return _platosBox.values.where((plato) => _normalizeDate(plato.fecha) == fechaNormalizada).toList();
  }

  List<Alimento> get alimentosManuales => _isInitialized ? _alimentosBox.values.toList() : [];
  
  Plato? getPlatoById(String id) {
    return _isInitialized ? _platosBox.get(id) : null;
  }

  Future<void> agregarPlato({
    required TipoPlato tipo,
    required List<Alimento> alimentos,
    DateTime? fecha,
  }) async {
    if (!_isInitialized) return;
    final fechaNormalizada = _normalizeDate(fecha ?? DateTime.now());
    final calorias = alimentos.fold<double>(0, (sum, item) => sum + item.calorias);

    final nuevoPlato = Plato(
      id: _uuid.v4(),
      tipo: tipo,
      fecha: fechaNormalizada,
      alimentos: alimentos,
      totalCalorias: calorias,
    );

    await _platosBox.put(nuevoPlato.id, nuevoPlato);
    _syncProvider?.syncDocumentToFirestore('platos', nuevoPlato.id, nuevoPlato.toJson());
    notifyListeners();
  }

  Future<void> editarPlato(Plato platoActualizado) async {
    if (!_isInitialized) return;
    platoActualizado.totalCalorias = platoActualizado.alimentos.fold<double>(0, (sum, item) => sum + item.calorias);
    await _platosBox.put(platoActualizado.id, platoActualizado);
    _syncProvider?.syncDocumentToFirestore('platos', platoActualizado.id, platoActualizado.toJson());
    notifyListeners();
  }

  Future<void> eliminarPlato(String platoId) async {
    if (!_isInitialized) return;
    await _platosBox.delete(platoId);
    _syncProvider?.deleteDocumentFromFirestore('platos', platoId);
    notifyListeners();
  }
  
  Future<void> addAlimentoManual(Alimento alimento) async {
    if (!_isInitialized) return;
    final nuevoAlimento = alimento.copyWith(id: _uuid.v4());
    await _alimentosBox.put(nuevoAlimento.id, nuevoAlimento);
    _syncProvider?.syncDocumentToFirestore('alimentos', nuevoAlimento.id, nuevoAlimento.toJson());
    notifyListeners();
  }

  Future<void> removeAlimentoManual(String alimentoId) async {
    if (!_isInitialized) return;
    await _alimentosBox.delete(alimentoId);
    _syncProvider?.deleteDocumentFromFirestore('alimentos', alimentoId);
    notifyListeners();
  }

  double getCaloriasConsumidasPorFecha(DateTime fecha) {
    final platos = getPlatosPorFecha(fecha);
    return platos.fold(0.0, (sum, plato) => sum + plato.totalCalorias);
  }

  Map<String, double> getMacrosPorFecha(DateTime fecha) {
    final platos = getPlatosPorFecha(fecha);
    Map<String, double> macros = {'proteinas': 0, 'carbohidratos': 0, 'grasas': 0};

    for (var plato in platos) {
      for (var alimento in plato.alimentos) {
        macros['proteinas'] = (macros['proteinas'] ?? 0) + alimento.proteinas;
        macros['carbohidratos'] = (macros['carbohidratos'] ?? 0) + alimento.carbohidratos;
        macros['grasas'] = (macros['grasas'] ?? 0) + alimento.grasas;
      }
    }
    return macros;
  }
  
  Future<void> replaceAllData(List<Plato> platos, List<Alimento> alimentos) async {
    if (!_isInitialized) return;
    await _platosBox.clear();
    await _alimentosBox.clear();
    for (var plato in platos) {
      await _platosBox.put(plato.id, plato);
    }
    for (var alimento in alimentos) {
      await _alimentosBox.put(alimento.id, alimento);
    }
    notifyListeners();
  }

  DateTime _normalizeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
