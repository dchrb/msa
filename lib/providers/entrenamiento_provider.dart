// lib/providers/entrenamiento_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:msa/models/ejercicio.dart';
import 'package:msa/models/sesion_entrenamiento.dart';
import 'package:uuid/uuid.dart';

class EntrenamientoProvider with ChangeNotifier {
  late Box<Ejercicio> _ejerciciosBox;
  late Box<SesionEntrenamiento> _sesionesBox;
  bool isInitialized = false;

  EntrenamientoProvider() {
    _init();
  }

  Future<void> _init() async {
    _ejerciciosBox = Hive.box<Ejercicio>('ejerciciosBox');
    _sesionesBox = Hive.box<SesionEntrenamiento>('sesionesBox');
    isInitialized = true;
    _crearEjerciciosPorDefecto();
    notifyListeners();
  }

  List<Ejercicio> get ejercicios => _ejerciciosBox.values.toList();
  List<SesionEntrenamiento> get sesiones => _sesionesBox.values.toList()..sort((a, b) => b.fecha.compareTo(a.fecha));

  Ejercicio? getEjercicioPorId(String id) {
    return _ejerciciosBox.get(id);
  }

  bool existeEjercicio(String nombre) {
    return _ejerciciosBox.values.any((ejercicio) => ejercicio.nombre.toLowerCase() == nombre.toLowerCase());
  }

  Future<void> agregarEjercicio(String nombre, TipoEjercicio tipo, {String? musculoPrincipal}) async {
    final nuevoEjercicio = Ejercicio(
      id: const Uuid().v4(),
      nombre: nombre,
      tipo: tipo,
      musculoPrincipal: musculoPrincipal,
    );
    await _ejerciciosBox.put(nuevoEjercicio.id, nuevoEjercicio);
    notifyListeners();
  }

  Future<void> editarEjercicio(Ejercicio ejercicio) async {
    await _ejerciciosBox.put(ejercicio.id, ejercicio);
    notifyListeners();
  }

  Future<void> eliminarEjercicio(String ejercicioId) async {
    await _ejerciciosBox.delete(ejercicioId);
    notifyListeners();
  }

  Future<void> agregarSesion(SesionEntrenamiento sesion) async {
    await _sesionesBox.put(sesion.id, sesion);
    notifyListeners();
  }

  Future<void> editarSesion(SesionEntrenamiento sesion) async {
    await _sesionesBox.put(sesion.id, sesion);
    notifyListeners();
  }

  Future<void> eliminarSesion(String sesionId) async {
    await _sesionesBox.delete(sesionId);
    notifyListeners();
  }

  void _crearEjerciciosPorDefecto() {
    if (_ejerciciosBox.isEmpty) {
      agregarEjercicio("Press de Banca", TipoEjercicio.fuerza, musculoPrincipal: "Pecho");
      agregarEjercicio("Sentadilla", TipoEjercicio.fuerza, musculoPrincipal: "Piernas");
      agregarEjercicio("Peso Muerto", TipoEjercicio.fuerza, musculoPrincipal: "Espalda");
      agregarEjercicio("Correr en cinta", TipoEjercicio.cardio);
      agregarEjercicio("Estiramiento de isquiotibiales", TipoEjercicio.flexibilidad);
    }
  }

  Map<DateTime, double> getVolumenUltimos7Dias() {
    final Map<DateTime, double> volumenPorDia = {};
    final hoy = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final fecha = hoy.subtract(Duration(days: i));
      final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);

      double totalVolumen = 0;
      for (var sesion in sesiones) {
        final fechaSesionSinHora = DateTime(sesion.fecha.year, sesion.fecha.month, sesion.fecha.day);
        if (fechaSesionSinHora == fechaSinHora) {
          for (var detalle in sesion.detalles) {
            for (var serie in detalle.series) {
              totalVolumen += serie.repeticiones * (serie.pesoKg ?? 0);
            }
          }
        }
      }
      volumenPorDia[fechaSinHora] = totalVolumen;
    }
    return volumenPorDia;
  }
}