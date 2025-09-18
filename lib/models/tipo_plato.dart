import 'package:hive/hive.dart';

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