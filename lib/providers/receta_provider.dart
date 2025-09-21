// lib/providers/receta_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:msa/models/alimento.dart';
import 'package:msa/models/receta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class RecetaProvider with ChangeNotifier {
  final List<Receta> _recetas = [];
  final Uuid _uuid = const Uuid();

  List<Receta> get recetas => [..._recetas];

  RecetaProvider() {
    _cargarRecetas();
  }

  Future<void> _cargarRecetas() async {
    final prefs = await SharedPreferences.getInstance();
    final recetasString = prefs.getString('recetas_guardadas');
    if (recetasString != null) {
      try {
        final List<dynamic> recetasJson = json.decode(recetasString);
        _recetas.clear();
        _recetas.addAll(recetasJson.map((json) => Receta.fromJson(json)).toList());
      } catch (e) {
        // Si hay un error en el formato, se borran los datos corruptos para evitar crashes.
        await prefs.remove('recetas_guardadas');
        _recetas.clear();
      }
    }
    notifyListeners();
  }

  Future<void> _guardarRecetas() async {
    final prefs = await SharedPreferences.getInstance();
    final recetasString = json.encode(_recetas.map((r) => r.toJson()).toList());
    await prefs.setString('recetas_guardadas', recetasString);
  }

  // --- NUEVA FUNCIÓN: Agrega una receta desde el formato de la API TheMealDB ---
  Future<void> agregarRecetaDesdeApi(Map<String, dynamic> apiReceta) async {
    final nombre = apiReceta['strMeal'] as String? ?? 'Receta sin nombre';
    final imageUrl = apiReceta['strMealThumb'] as String?;

    // 1. Extraer ingredientes y medidas
    final List<Alimento> alimentos = [];
    for (int i = 1; i <= 20; i++) {
      final ingrediente = apiReceta['strIngredient$i'] as String?;
      final medida = apiReceta['strMeasure$i'] as String?;

      if (ingrediente != null && ingrediente.trim().isNotEmpty) {
        alimentos.add(Alimento(
          id: _uuid.v4(),
          nombre: '$medida $ingrediente'.trim(),
          calorias: 0, // Se deja en 0, el usuario puede editarlo después
          proteinas: 0,
          carbohidratos: 0,
          grasas: 0,
          porcionGramos: 0, // Añadido el parámetro requerido
        ));
      }
    }

    // 2. Extraer y formatear los pasos de la preparación
    final instrucciones = apiReceta['strInstructions'] as String? ?? '';
    final pasos = instrucciones
        .split(RegExp(r'\r\n|\n')) // Divide por saltos de línea
        .where((paso) => paso.trim().isNotEmpty) // Elimina líneas vacías
        .map((paso) => paso.trim())
        .toList();

    // 3. Crear la nueva receta
    final nuevaReceta = Receta(
      id: _uuid.v4(),
      nombre: nombre,
      alimentos: alimentos,
      pasos: pasos,
      imageUrl: imageUrl,
    );

    _recetas.add(nuevaReceta);
    await _guardarRecetas();
    notifyListeners();
  }

  Future<void> eliminarReceta(String id) async {
    _recetas.removeWhere((receta) => receta.id == id);
    await _guardarRecetas();
    notifyListeners();
  }
  
  Future<void> agregarReceta({
    required String nombre,
    List<Alimento> alimentos = const [],
    List<String> pasos = const [],
    String? imageUrl,
  }) async {
    if (nombre.isEmpty) return;

    final nuevaReceta = Receta(
      id: _uuid.v4(),
      nombre: nombre,
      alimentos: alimentos,
      pasos: pasos,
      imageUrl: imageUrl,
    );

    _recetas.add(nuevaReceta);
    await _guardarRecetas();
    notifyListeners();
  }

  // --- MÉTODO PARA SINCRONIZACIÓN ---
  /// Reemplaza todas las recetas locales con las de la nube.
  Future<void> replaceAll(List<Receta> nuevasRecetas) async {
    _recetas.clear();
    _recetas.addAll(nuevasRecetas);
    await _guardarRecetas();
    notifyListeners();
  }
}
