// lib/providers/food_provider.dart

import 'package:flutter/material.dart';
import 'package:msa/models/plato.dart';
import 'package:msa/models/alimento.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FoodProvider with ChangeNotifier {
  late Box<Plato> _platosBox;
  late Box<Alimento> _alimentosManualesBox;

  // Nuevas variables para almacenar los totales en caché
  double _caloriasSemanaActual = 0.0;
  double _caloriasMesActual = 0.0;

  FoodProvider() {
    _platosBox = Hive.box<Plato>('platosBox');
    _alimentosManualesBox = Hive.box<Alimento>('alimentosManualesBox');
    _actualizarCacheTotales();
  }

  List<Plato> get platos => _platosBox.values.toList()..sort((a, b) => b.fecha.compareTo(a.fecha));

  List<Alimento> get alimentosManuales => _alimentosManualesBox.values.toList();

  void agregarAlimentoManual(Alimento alimento) {
    _alimentosManualesBox.put(alimento.id, alimento);
    notifyListeners();
  }

  void eliminarAlimentoManual(String alimentoId) {
    _alimentosManualesBox.delete(alimentoId);
    notifyListeners();
  }

  void agregarPlato(TipoPlato tipo, List<Alimento> alimentos, DateTime fecha) {
    if (alimentos.isEmpty) return;
    
    final double totalCalorias = alimentos.fold(0.0, (sum, alimento) => sum + alimento.calorias);
    
    final id = const Uuid().v4();
    final nuevoPlato = Plato(
      id: id,
      tipo: tipo,
      fecha: fecha,
      alimentos: alimentos,
      totalCalorias: totalCalorias,
    );
    _platosBox.put(id, nuevoPlato);
    _actualizarCacheTotales();
    notifyListeners();
  }

  void eliminarPlato(String id) {
    _platosBox.delete(id);
    _actualizarCacheTotales();
    notifyListeners();
  }
  
  void editarPlato(Plato platoActualizado) {
    platoActualizado.totalCalorias = platoActualizado.alimentos.fold(0.0, (sum, al) => sum + al.calorias);
    _platosBox.put(platoActualizado.id, platoActualizado);
    _actualizarCacheTotales();
    notifyListeners();
  }

  // Se refactorizó la lógica para que los getters retornen el valor en caché
  double getCaloriasPorFecha(DateTime fecha) {
    double total = 0.0;
    final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);

    for (var plato in _platosBox.values) {
      final fechaPlatoSinHora = DateTime(plato.fecha.year, plato.fecha.month, plato.fecha.day);
      if (fechaPlatoSinHora == fechaSinHora) {
        total += plato.totalCalorias;
      }
    }
    return total;
  }

  // Ahora solo se devuelve el valor en caché
  double getCaloriasSemanaActual() {
    return _caloriasSemanaActual;
  }

  // Ahora solo se devuelve el valor en caché
  double getCaloriasMesActual() {
    return _caloriasMesActual;
  }
  
  List<Plato> getPlatosPorFecha(DateTime fecha) {
    final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);
    return _platosBox.values.where((plato) {
      final fechaPlatoSinHora = DateTime(plato.fecha.year, plato.fecha.month, plato.fecha.day);
      return fechaPlatoSinHora == fechaSinHora;
    }).toList();
  }

  Map<DateTime, double> getCaloriasUltimos7Dias() {
    final Map<DateTime, double> caloriasPorDia = {};
    final hoy = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final fecha = hoy.subtract(Duration(days: i));
      final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);
      
      caloriasPorDia[fechaSinHora] = getCaloriasPorFecha(fechaSinHora);
    }
    return caloriasPorDia;
  }

  // Nuevo método privado para actualizar los valores en caché
  void _actualizarCacheTotales() {
    final ahora = DateTime.now();
    final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    _caloriasSemanaActual = 0.0;
    _caloriasMesActual = 0.0;
    
    for (var plato in _platosBox.values) {
      final fechaPlato = plato.fecha;
      // Recálculo del total semanal
      if (fechaPlato.isAfter(inicioSemana.subtract(const Duration(days: 1))) && fechaPlato.isBefore(ahora.add(const Duration(days: 1)))) {
        _caloriasSemanaActual += plato.totalCalorias;
      }
      // Recálculo del total mensual
      if (fechaPlato.year == ahora.year && fechaPlato.month == ahora.month) {
        _caloriasMesActual += plato.totalCalorias;
      }
    }
  }
}