import 'package:hive/hive.dart';

@HiveType(typeId: 8)
enum TipoEjercicio {
  @HiveField(0)
  fuerza,

  @HiveField(1)
  cardio,

  @HiveField(2)
  flexibilidad,
}