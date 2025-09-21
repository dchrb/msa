import 'package:hive/hive.dart';

part 'racha.g.dart';

@HiveType(typeId: 16) // Aseguramos un typeId único
class Racha extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String descripcion;

  @HiveField(3)
  final String icono;

  @HiveField(4)
  int rachaActual;

  @HiveField(5)
  int rachaMasAlta;

  @HiveField(6)
  DateTime? ultimaVezActualizada;

  Racha({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    this.rachaActual = 0,
    this.rachaMasAlta = 0,
    this.ultimaVezActualizada,
  });
}
