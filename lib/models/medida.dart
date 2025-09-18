// lib/models/medida.dart

import 'package:hive/hive.dart';

part 'medida.g.dart';

@HiveType(typeId: 1)
class Medida extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  DateTime fecha;
  @HiveField(2)
  double peso;
  @HiveField(3)
  double altura;
  @HiveField(4)
  double? pecho;
  @HiveField(5)
  double? brazo;
  @HiveField(6)
  double? cintura;
  @HiveField(7)
  double? caderas;
  @HiveField(8)
  double? muslo;

  Medida({
    required this.id,
    required this.fecha,
    required this.peso,
    required this.altura,
    this.pecho,
    this.brazo,
    this.cintura,
    this.caderas,
    this.muslo,
  });

  // Getter para calcular el IMC automáticamente
  double get imc {
    if (altura <= 0) return 0;
    // La altura se guarda en cm, la convertimos a metros para la fórmula
    final alturaEnMetros = altura / 100;
    return peso / (alturaEnMetros * alturaEnMetros);
  }
}