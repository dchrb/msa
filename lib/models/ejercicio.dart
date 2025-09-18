// lib/models/ejercicio.dart

import 'package:hive/hive.dart';

part 'ejercicio.g.dart';

@HiveType(typeId: 8)
enum TipoEjercicio {
  @HiveField(0)
  fuerza,
  
  @HiveField(1)
  cardio,

  @HiveField(2)
  flexibilidad,
}

@HiveType(typeId: 7)
class Ejercicio extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  TipoEjercicio tipo;

  @HiveField(3)
  String? musculoPrincipal;

  Ejercicio({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.musculoPrincipal,
  });
}