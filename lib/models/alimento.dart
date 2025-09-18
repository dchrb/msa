import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'alimento.g.dart';

@HiveType(typeId: 3)
class Alimento extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  double calorias;

  @HiveField(3)
  double proteinas;

  @HiveField(4)
  double carbohidratos;

  @HiveField(5)
  double grasas;

  @HiveField(6)
  double porcionGramos;

  @HiveField(7)
  String? idApi;

  @HiveField(8)
  bool esManual;

  Alimento({
    String? id,
    required this.nombre,
    required this.calorias,
    required this.proteinas,
    required this.carbohidratos,
    required this.grasas,
    required this.porcionGramos,
    this.idApi,
    this.esManual = false,
  }) : id = id ?? const Uuid().v4();
}