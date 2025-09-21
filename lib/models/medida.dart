
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'medida.g.dart';

@HiveType(typeId: 1)
class Medida extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime fecha;

  @HiveField(2)
  String tipo; // Ej: 'Peso', 'Altura', 'Cintura'

  @HiveField(3)
  double valor; // El valor de la medida

  Medida({
    required this.id,
    required this.fecha,
    required this.tipo,
    required this.valor,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': Timestamp.fromDate(fecha),
        'tipo': tipo,
        'valor': valor,
      };

  factory Medida.fromJson(Map<String, dynamic> json) => Medida(
        id: json['id'],
        fecha: (json['fecha'] as Timestamp).toDate(),
        tipo: json['tipo'],
        valor: json['valor']?.toDouble() ?? 0.0,
      );
}
