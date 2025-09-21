import 'package:hive/hive.dart';
import 'package:msa/models/tipo_ejercicio.dart';

export 'package:msa/models/tipo_ejercicio.dart';

part 'ejercicio.g.dart';

@HiveType(typeId: 7)
class Ejercicio extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  TipoEjercicio tipo;

  @HiveField(3)
  String? musculoPrincipal;

  Ejercicio({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.musculoPrincipal,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo.name,
        'musculoPrincipal': musculoPrincipal,
      };

  factory Ejercicio.fromJson(Map<String, dynamic> json) => Ejercicio(
        id: json['id'],
        nombre: json['nombre'],
        tipo: TipoEjercicio.values.byName(json['tipo'] ?? 'fuerza'),
        musculoPrincipal: json['musculoPrincipal'],
      );
}
