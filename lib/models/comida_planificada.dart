// lib/models/comida_planificada.dart

import 'package:hive/hive.dart';
import 'package:msa/models/plato.dart'; // Para usar el enum TipoPlato

part 'comida_planificada.g.dart';

@HiveType(typeId: 16) // Nuevo typeId único
class ComidaPlanificada extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  TipoPlato tipo;

  @HiveField(3)
  bool completado;

  ComidaPlanificada({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.completado = false,
  });
}