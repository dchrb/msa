import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:msa/models/detalle_ejercicio.dart';

part 'sesion_entrenamiento.g.dart';

@HiveType(typeId: 15)
class SesionEntrenamiento extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  DateTime fecha;

  @HiveField(3)
  List<DetalleEjercicio> detalles;

  @HiveField(4)
  double? duracionMinutos;

  SesionEntrenamiento({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.detalles,
    this.duracionMinutos,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'fecha': Timestamp.fromDate(fecha),
        'detalles': detalles.map((d) => d.toJson()).toList(),
        'duracionMinutos': duracionMinutos,
      };

  factory SesionEntrenamiento.fromJson(Map<String, dynamic> json) => SesionEntrenamiento(
        id: json['id'],
        nombre: json['nombre'],
        fecha: (json['fecha'] as Timestamp).toDate(),
        detalles: (json['detalles'] as List<dynamic>)
            .map((d) => DetalleEjercicio.fromJson(d))
            .toList(),
        duracionMinutos: (json['duracionMinutos'] as num?)?.toDouble(),
      );
}
