import 'package:hive/hive.dart';

part 'tipo_plato.g.dart';

@HiveType(typeId: 17) // ID único para el enum
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
