// lib/models/meta_objetivo.dart

class MetaObjetivo {
  final String id;
  final String titulo;
  final String descripcion;
  final int objetivoRacha; // El número de días seguidos para completarla
  int rachaActual; // Cuántos días seguidos lleva el usuario
  DateTime? ultimaFechaCumplida; // Para saber si la racha se rompió

  MetaObjetivo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.objetivoRacha,
    this.rachaActual = 0,
    this.ultimaFechaCumplida,
  });

  // Método para saber si la meta ya se completó
  bool get completada => rachaActual >= objetivoRacha;
}