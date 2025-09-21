import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:msa/models/alimento.dart';

part 'receta.g.dart';

@HiveType(typeId: 12)
@immutable
class Receta {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String nombre;
  @HiveField(2)
  final List<Alimento> alimentos;
  @HiveField(3)
  final List<String> pasos;
  @HiveField(4)
  final double totalCalorias;
  @HiveField(5)
  final double totalProteinas;
  @HiveField(6)
  final double totalCarbohidratos;
  @HiveField(7)
  final double totalGrasas;
  @HiveField(8)
  final String? imageUrl; // --- NUEVO: Campo para la URL de la imagen

  const Receta({
    required this.id,
    required this.nombre,
    required this.alimentos,
    this.pasos = const [],
    this.imageUrl, // --- NUEVO
    // Los totales se calculan en el provider, aquí los hacemos opcionales
    this.totalCalorias = 0.0,
    this.totalProteinas = 0.0,
    this.totalCarbohidratos = 0.0,
    this.totalGrasas = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'alimentos': alimentos.map((a) => a.toJson()).toList(),
      'pasos': pasos,
      'imageUrl': imageUrl, // --- NUEVO
      'totalCalorias': totalCalorias,
      'totalProteinas': totalProteinas,
      'totalCarbohidratos': totalCarbohidratos,
      'totalGrasas': totalGrasas,
    };
  }

  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      alimentos: (json['alimentos'] as List? ?? [])
          .map((i) => Alimento.fromJson(i as Map<String, dynamic>))
          .toList(),
      pasos: List<String>.from(json['pasos'] as List? ?? []),
      imageUrl: json['imageUrl'] as String?, // --- NUEVO
      totalCalorias: (json['totalCalorias'] ?? 0.0) as double,
      totalProteinas: (json['totalProteinas'] ?? 0.0) as double,
      totalCarbohidratos: (json['totalCarbohidratos'] ?? 0.0) as double,
      totalGrasas: (json['totalGrasas'] ?? 0.0) as double,
    );
  }

  // Método para crear una copia con valores modificados
  Receta copyWith({
    String? id,
    String? nombre,
    List<Alimento>? alimentos,
    List<String>? pasos,
    String? imageUrl,
    double? totalCalorias,
    double? totalProteinas,
    double? totalCarbohidratos,
    double? totalGrasas,
  }) {
    return Receta(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      alimentos: alimentos ?? this.alimentos,
      pasos: pasos ?? this.pasos,
      imageUrl: imageUrl ?? this.imageUrl,
      totalCalorias: totalCalorias ?? this.totalCalorias,
      totalProteinas: totalProteinas ?? this.totalProteinas,
      totalCarbohidratos: totalCarbohidratos ?? this.totalCarbohidratos,
      totalGrasas: totalGrasas ?? this.totalGrasas,
    );
  }
}
