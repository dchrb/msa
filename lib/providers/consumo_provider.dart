import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:msa/models/comida_consumida.dart';
import 'package:uuid/uuid.dart';

class ConsumoProvider with ChangeNotifier {
  late Box<ComidaConsumida> _consumoBox;
  bool _isInitialized = false;

  // Meta calórica diaria. En el futuro, esto podría ser configurable por el usuario.
  final int _metaCaloricaDiaria = 2000;

  Box<ComidaConsumida> get consumoBox => _consumoBox;
  bool get isInitialized => _isInitialized;
  int get metaCaloricaDiaria => _metaCaloricaDiaria;

  ConsumoProvider() {
    _init();
  }

  Future<void> _init() async {
    _consumoBox = await Hive.openBox<ComidaConsumida>('comidasConsumidasBox');
    _isInitialized = true;
    notifyListeners();
  }

  // Calcula las calorías consumidas en el día de hoy
  int get caloriasConsumidasHoy {
    if (!_isInitialized) return 0;

    final ahora = DateTime.now();
    final inicioHoy = DateTime(ahora.year, ahora.month, ahora.day);
    final finHoy = inicioHoy.add(const Duration(days: 1));

    return _consumoBox.values
        .where((consumo) => 
            consumo.fecha.isAfter(inicioHoy) && consumo.fecha.isBefore(finHoy))
        .fold(0, (sum, item) => sum + item.calorias);
  }

  // Método para registrar una nueva comida consumida
  Future<void> registrarComida(String nombre, int calorias) async {
    if (!_isInitialized) return;
    final nuevoConsumo = ComidaConsumida(
      id: const Uuid().v4(),
      nombre: nombre,
      calorias: calorias,
      fecha: DateTime.now(),
    );
    await _consumoBox.put(nuevoConsumo.id, nuevoConsumo);
    notifyListeners(); // Notificamos manualmente
  }

   // Método para obtener todos los registros (útil para historial, debug, etc.)
  List<ComidaConsumida> get todosLosConsumos => _consumoBox.values.toList();

}
