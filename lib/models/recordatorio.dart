import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'recordatorio.g.dart';

@HiveType(typeId: 0)
class Recordatorio extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int hora;

  @HiveField(2)
  int minuto;

  @HiveField(3)
  String mensaje;

  @HiveField(4)
  bool activado;

  Recordatorio({
    required this.id,
    required this.hora,
    required this.minuto,
    required this.mensaje,
    required this.activado,
  });

  // Getter para facilitar el uso con TimeOfDay
  TimeOfDay get timeOfDay => TimeOfDay(hour: hora, minute: minuto);
}
