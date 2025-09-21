import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:msa/models/alimento.dart';
import 'package:msa/models/tipo_plato.dart';

export 'package:msa/models/tipo_plato.dart';

part 'plato.g.dart';

@HiveType(typeId: 4)
class Plato extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  TipoPlato tipo;

  @HiveField(2)
  DateTime fecha;

  @HiveField(3)
  List<Alimento> alimentos;

  @HiveField(4)
  double totalCalorias;

  Plato({
    required this.id,
    required this.tipo,
    required this.fecha,
    required this.alimentos,
    required this.totalCalorias,
  });

  // Convierte el objeto Plato a un Map para Firestore
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo.name, // Guardar el nombre del enum como String
        'fecha': Timestamp.fromDate(fecha),
        // Convertir cada Alimento en la lista a su representación JSON
        'alimentos': alimentos.map((alimento) => alimento.toJson()).toList(),
        'totalCalorias': totalCalorias,
      };

  // Crea un objeto Plato desde un Map (útil al leer de Firestore)
  factory Plato.fromJson(Map<String, dynamic> json) => Plato(
        id: json['id'],
        // Convertir el String de vuelta a un enum
        tipo: TipoPlato.values.byName(json['tipo'] ?? 'snack'),
        fecha: (json['fecha'] as Timestamp).toDate(),
        // Convertir cada mapa en la lista de nuevo a un objeto Alimento
        alimentos: (json['alimentos'] as List<dynamic>)
            .map((alimentoJson) => Alimento.fromJson(alimentoJson))
            .toList(),
        totalCalorias: json['totalCalorias']?.toDouble() ?? 0.0,
      );
}
