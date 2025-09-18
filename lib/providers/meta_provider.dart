// lib/providers/meta_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:msa/models/meta_objetivo.dart'; 

class MetaProvider with ChangeNotifier {
  final List<MetaObjetivo> _metas = [
    MetaObjetivo(id: 'agua_racha_3', titulo: 'Racha de 3 Días (Agua)', descripcion: 'Cumple tu meta de agua por 3 días seguidos.', objetivoRacha: 3),
    MetaObjetivo(id: 'agua_racha_7', titulo: 'Semana Saludable (Agua)', descripcion: 'Cumple tu meta de agua por 7 días seguidos.', objetivoRacha: 7),
    MetaObjetivo(id: 'entrenamiento_racha_3', titulo: 'Semana Activa', descripcion: 'Registra un entrenamiento por 3 días seguidos.', objetivoRacha: 3),
    MetaObjetivo(id: 'entrenamiento_racha_7', titulo: 'Imparable', descripcion: 'Registra un entrenamiento por 7 días seguidos.', objetivoRacha: 7),
    MetaObjetivo(id: 'desayuno_racha_5', titulo: 'Desayuno Consistente', descripcion: 'Registra el desayuno por 5 días seguidos.', objetivoRacha: 5),
    MetaObjetivo(id: 'calorias_racha_7', titulo: 'Semana de Control', descripcion: 'Mantente en tu meta calórica por 7 días seguidos.', objetivoRacha: 7),
    MetaObjetivo(id: 'registro_racha_15', titulo: 'Hábito Creado', descripcion: 'Registra cualquier actividad por 15 días seguidos.', objetivoRacha: 15),
    MetaObjetivo(id: 'medidas_racha_4', titulo: 'Constancia de Medidas', descripcion: 'Registra tus medidas por 4 semanas consecutivas.', objetivoRacha: 4), // ¡Nueva meta!
  ];

  Map<String, MetaObjetivo> _progresoMetas = {};

  MetaProvider() {
    _cargarProgresoMetas();
  }

  List<MetaObjetivo> get metas => _metas.map((m) => _progresoMetas[m.id] ?? m).toList();

  Future<void> _cargarProgresoMetas() async {
    final prefs = await SharedPreferences.getInstance();
    for (var meta in _metas) {
      final racha = prefs.getInt('meta_${meta.id}_racha') ?? 0;
      final ultimaFecha = prefs.getString('meta_${meta.id}_fecha');
      
      meta.rachaActual = racha;
      if (ultimaFecha != null) {
        meta.ultimaFechaCumplida = DateTime.parse(ultimaFecha);
      }
      _progresoMetas[meta.id] = meta;
    }
    notifyListeners();
  }

  Future<void> _guardarProgreso(MetaObjetivo meta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('meta_${meta.id}_racha', meta.rachaActual);
    await prefs.setString('meta_${meta.id}_fecha', meta.ultimaFechaCumplida!.toIso8601String());
  }

  void actualizarRachaAgua() {
    actualizarRacha('agua');
  }

  void actualizarRachaEntrenamiento() {
    actualizarRacha('entrenamiento');
  }

  void actualizarRachaDesayuno() {
    actualizarRacha('desayuno');
  }

  void actualizarRachaCalorias() {
    actualizarRacha('calorias');
  }

  void actualizarRachaRegistro() {
    actualizarRacha('registro');
  }

  void actualizarRachaMedidas() { // Nuevo método
    actualizarRacha('medidas');
  }

  void actualizarRacha(String tipoMeta) {
    final hoy = DateTime.now();
    final ayer = hoy.subtract(const Duration(days: 1));
    final metasDelTipo = _metas.where((m) => m.id.startsWith(tipoMeta));

    for (var meta in metasDelTipo) {
      if (meta.completada) continue;

      final ultimaFecha = meta.ultimaFechaCumplida;
      final ultimaFechaSinHora = ultimaFecha != null ? DateTime(ultimaFecha.year, ultimaFecha.month, ultimaFecha.day) : null;
      final ayerSinHora = DateTime(ayer.year, ayer.month, ayer.day);
      final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);

      if (ultimaFecha == null || ultimaFechaSinHora != ayerSinHora) {
        meta.rachaActual = 1;
        meta.ultimaFechaCumplida = hoy;
      } else {
        meta.rachaActual++;
        meta.ultimaFechaCumplida = hoy;
      }
      _guardarProgreso(meta);
    }
    notifyListeners();
  }
}