// lib/models/plato.dart

import 'package:hive/hive.dart';
import 'package:msa/models/alimento.dart';

part 'plato.g.dart';

// Es buena práctica definir el enum aquí también si está muy relacionado
@HiveType(typeId: 5)
enum TipoPlato {
  @HiveField(0)
  desayuno,
  
  @HiveField(1)
  almuerzo,

  @HiveField(2)
  cena,

  @HiveField(3)
  snack,
}

@HiveType(typeId: 4)
class Plato extends HiveObject {
  @HiveField(0)
  final String id; // El ID nunca debe cambiar, así que lo mantenemos final

  @HiveField(1)
  TipoPlato tipo; // <-- CAMBIO: Eliminamos 'final'

  @HiveField(2)
  DateTime fecha; // <-- CAMBIO: Eliminamos 'final'

  @HiveField(3)
  List<Alimento> alimentos; // <-- CAMBIO: Eliminamos 'final'

  @HiveField(4)
  double totalCalorias; // <-- CAMBIO: Eliminamos 'final'

  Plato({
    required this.id,
    required this.tipo,
    required this.fecha,
    required this.alimentos,
    required this.totalCalorias,
  });
}