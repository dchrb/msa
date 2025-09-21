import 'package:hive/hive.dart';

part 'comida_consumida.g.dart';

// He elegido el typeId 17, asumiendo que está libre.
@HiveType(typeId: 17)
class ComidaConsumida extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final int calorias;

  @HiveField(3)
  final DateTime fecha;

  ComidaConsumida({
    required this.id,
    required this.nombre,
    required this.calorias,
    required this.fecha,
  });

   Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'calorias': calorias,
        'fecha': fecha.toIso8601String(),
      };

  factory ComidaConsumida.fromJson(Map<String, dynamic> json) => ComidaConsumida(
        id: json['id'],
        nombre: json['nombre'],
        calorias: json['calorias'],
        fecha: DateTime.parse(json['fecha']),
      );
}
