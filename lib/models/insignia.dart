import 'package:hive/hive.dart';

part 'insignia.g.dart';

@HiveType(typeId: 15) // Un ID de tipo único para Hive
class Insignia extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  int nivelAlcanzado;

  // Este es el modelo de datos puro que se guarda en la base de datos.
  // Solo necesitamos saber QUÉ insignia es (el id) y QUÉ nivel ha alcanzado el usuario.
  // Toda la lógica compleja (nombre, descripción, progreso, etc.)
  // se gestionará en el InsigniaProvider basándose en este 'id'.

  Insignia({
    required this.id,
    this.nivelAlcanzado = 0,
  });
}
