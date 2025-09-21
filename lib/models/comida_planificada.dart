import 'package:hive/hive.dart';
import 'package:msa/models/plato.dart';

part 'comida_planificada.g.dart';

@HiveType(typeId: 16)
class ComidaPlanificada extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  TipoPlato tipo;

  @HiveField(3)
  bool completado;

  @HiveField(4) // Nuevo campo para el día de la semana
  int diaDeLaSemana; // 1: Lunes, 7: Domingo

  ComidaPlanificada({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.completado = false,
    required this.diaDeLaSemana,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo.toString(), // Guardar el enum como string
        'completado': completado,
        'diaDeLaSemana': diaDeLaSemana,
      };

  factory ComidaPlanificada.fromJson(Map<String, dynamic> json) => ComidaPlanificada(
        id: json['id'],
        nombre: json['nombre'],
        tipo: TipoPlato.values.firstWhere((e) => e.toString() == json['tipo']),
        completado: json['completado'] ?? false,
        diaDeLaSemana: json['diaDeLaSemana'],
      );
}
