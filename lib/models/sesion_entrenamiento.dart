// lib/models/sesion_entrenamiento.dart

import 'package:hive/hive.dart';
import 'package:msa/models/ejercicio.dart';
import 'package:msa/models/detalle_ejercicio.dart'; // Mantén esta importación

part 'sesion_entrenamiento.g.dart';

@HiveType(typeId: 15)
class SesionEntrenamiento extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  DateTime fecha;

  @HiveField(3)
  List<DetalleEjercicio> detalles;

  SesionEntrenamiento({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.detalles,
  });
}