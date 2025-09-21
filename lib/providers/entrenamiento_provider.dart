import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:msa/models/ejercicio.dart';
import 'package:msa/models/sesion_entrenamiento.dart';
import 'package:msa/providers/sync_provider.dart';

class EntrenamientoProvider with ChangeNotifier {
  SyncProvider? _syncProvider;
  late Box<Ejercicio> _ejerciciosBox;
  late Box<SesionEntrenamiento> _sesionesBox;
  bool _isInitialized = false;

  // Meta de entrenamiento diaria (en minutos)
  final double _metaMinutosDiaria = 30.0; 

  EntrenamientoProvider() {
    _init();
  }

  void updateSyncProvider(SyncProvider? syncProvider) {
    _syncProvider = syncProvider;
    if (_isInitialized && _ejerciciosBox.isEmpty) {
      _crearEjerciciosPorDefecto();
    }
  }

  Future<void> _init() async {
    _ejerciciosBox = Hive.box<Ejercicio>('ejercicios'); // Corregido box name
    _sesionesBox = Hive.box<SesionEntrenamiento>('sesiones'); // Corregido box name
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;
  List<Ejercicio> get ejercicios => _ejerciciosBox.values.toList();
  List<SesionEntrenamiento> get sesiones => _sesionesBox.values.toList()..sort((a, b) => b.fecha.compareTo(a.fecha));

  // Getters para la pantalla de inicio
  double get minutosEntrenadosHoy { // <-- AÑADIDO
    if (!_isInitialized) return 0.0;
    return getMinutosTotalesPorFecha(DateTime.now());
  }
  double get metaMinutosDiaria => _metaMinutosDiaria; // <-- AÑADIDO

  Ejercicio? getEjercicioPorId(String id) {
    return _ejerciciosBox.get(id);
  }

  bool existeEjercicio(String nombre) {
    return _ejerciciosBox.values.any((ejercicio) => ejercicio.nombre.toLowerCase() == nombre.toLowerCase());
  }

  Future<void> agregarEjercicio(Ejercicio ejercicio) async {
    await _ejerciciosBox.put(ejercicio.id, ejercicio);
    await _syncProvider?.syncDocumentToFirestore('ejercicios', ejercicio.id, ejercicio.toJson());
    notifyListeners();
  }

  Future<void> editarEjercicio(Ejercicio ejercicio) async {
    await _ejerciciosBox.put(ejercicio.id, ejercicio);
    await _syncProvider?.syncDocumentToFirestore('ejercicios', ejercicio.id, ejercicio.toJson());
    notifyListeners();
  }

  Future<void> eliminarEjercicio(String ejercicioId) async {
    await _ejerciciosBox.delete(ejercicioId);
    await _syncProvider?.deleteDocumentFromFirestore('ejercicios', ejercicioId);
    notifyListeners();
  }

  Future<void> agregarSesion(SesionEntrenamiento sesion) async {
    await _sesionesBox.put(sesion.id, sesion);
    await _syncProvider?.syncDocumentToFirestore('sesiones', sesion.id, sesion.toJson());
    notifyListeners();
  }

  Future<void> editarSesion(SesionEntrenamiento sesion) async {
    await _sesionesBox.put(sesion.id, sesion);
    await _syncProvider?.syncDocumentToFirestore('sesiones', sesion.id, sesion.toJson());
    notifyListeners();
  }

  Future<void> eliminarSesion(String sesionId) async {
    await _sesionesBox.delete(sesionId);
    await _syncProvider?.deleteDocumentFromFirestore('sesiones', sesionId);
    notifyListeners();
  }

  Future<void> _crearEjerciciosPorDefecto() async {
    if (_ejerciciosBox.isNotEmpty) return;
    
    final ejerciciosDefault = [
      Ejercicio(id: const Uuid().v4(), nombre: "Press de Banca", tipo: TipoEjercicio.fuerza, musculoPrincipal: "Pecho"),
      Ejercicio(id: const Uuid().v4(), nombre: "Sentadilla", tipo: TipoEjercicio.fuerza, musculoPrincipal: "Piernas"),
      Ejercicio(id: const Uuid().v4(), nombre: "Peso Muerto", tipo: TipoEjercicio.fuerza, musculoPrincipal: "Espalda"),
      Ejercicio(id: const Uuid().v4(), nombre: "Correr en cinta", tipo: TipoEjercicio.cardio),
      Ejercicio(id: const Uuid().v4(), nombre: "Estiramiento de isquiotibiales", tipo: TipoEjercicio.flexibilidad),
    ];

    for (var ej in ejerciciosDefault) {
      await agregarEjercicio(ej);
    }
  }
  
  double getMinutosTotalesPorFecha(DateTime fecha) {
    final inicioDia = DateTime(fecha.year, fecha.month, fecha.day);
    final finDia = inicioDia.add(const Duration(days: 1));
    double totalMinutos = 0;

    for (var sesion in _sesionesBox.values) {
      if (!sesion.fecha.isBefore(inicioDia) && sesion.fecha.isBefore(finDia)) {
        totalMinutos += sesion.duracionMinutos ?? 0.0;
      }
    }
    return totalMinutos;
  }

  Future<void> replaceAllEjercicios(List<Ejercicio> ejercicios) async {
    await _ejerciciosBox.clear();
    for (var ejercicio in ejercicios) {
      await _ejerciciosBox.put(ejercicio.id, ejercicio);
    }
    notifyListeners();
  }

  Future<void> replaceAllSesiones(List<SesionEntrenamiento> sesiones) async {
    await _sesionesBox.clear();
    for (var sesion in sesiones) {
      await _sesionesBox.put(sesion.id, sesion);
    }
    notifyListeners();
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
              totalVolumen += serie.repeticiones * (serie.pesoKg ?? 0.0);
            }
          }
        }
      }
      volumenPorDia[fechaSinHora] = totalVolumen;
    }
    return volumenPorDia;
  }
}
