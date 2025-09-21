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

  TimeOfDay get timeOfDay => TimeOfDay(hour: hora, minute: minuto);

  Map<String, dynamic> toJson() => {
        'id': id,
        'hora': hora,
        'minuto': minuto,
        'mensaje': mensaje,
        'activado': activado,
      };

  factory Recordatorio.fromJson(Map<String, dynamic> json) => Recordatorio(
        id: json['id'],
        hora: json['hora'],
        minuto: json['minuto'],
        mensaje: json['mensaje'],
        activado: json['activado'],
      );
}
