import 'package:hive/hive.dart';

part 'tipo_ejercicio.g.dart';

@HiveType(typeId: 13)
enum TipoEjercicio {
  @HiveField(0)
  fuerza,
  
  @HiveField(1)
  cardio,
  
  @HiveField(2)
  flexibilidad,
  
  @HiveField(3)
  equilibrio,
  
  @HiveField(4)
  otro,
}
