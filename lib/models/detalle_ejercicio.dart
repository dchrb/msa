import 'package:hive/hive.dart';
import 'package:msa/models/serie.dart';

part 'detalle_ejercicio.g.dart';

@HiveType(typeId: 9)
class DetalleEjercicio extends HiveObject {
  @HiveField(0)
  final String ejercicioId;

  @HiveField(1)
  List<Serie> series;

  @HiveField(2)
  double? duracionMinutos;

  @HiveField(3)
  double? distanciaKm;

  @HiveField(4)
  int? repeticionesSinPeso;

  DetalleEjercicio({
    required this.ejercicioId,
    required this.series,
    this.duracionMinutos,
    this.distanciaKm,
    this.repeticionesSinPeso,
  });
}