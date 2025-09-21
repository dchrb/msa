// lib/pantallas/pantalla_historial_comidas.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/pantallas/pantalla_registro_plato_avanzado.dart';
import 'package:provider/provider.dart';

class PantallaHistorialComidas extends StatefulWidget {
  const PantallaHistorialComidas({super.key});

  @override
  State<PantallaHistorialComidas> createState() => _PantallaHistorialComidasState();
}

class _PantallaHistorialComidasState extends State<PantallaHistorialComidas> {
  DateTime _fechaSeleccionada = DateTime.now();

  void _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      locale: const Locale("es", "ES"),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final platosDeLaFecha = foodProvider.getPlatosPorFecha(_fechaSeleccionada);

    return Scaffold(
      body: Column(
        children: [
          _buildSummaryCards(foodProvider),
          _buildDatePicker(context),
          const Divider(),
          Expanded(
            child: platosDeLaFecha.isEmpty
                ? const Center(child: Text("No hay registros para esta fecha."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: platosDeLaFecha.length,
                    itemBuilder: (context, index) {
                      final plato = platosDeLaFecha[index];
                      final nombresAlimentos = plato.alimentos.map((a) => a.nombre).join(', ');

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          isThreeLine: true,
                          title: Text(
                            plato.tipo.toString().split('.').last.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "$nombresAlimentos\nTotal: ${plato.totalCalorias.toStringAsFixed(0)} kcal",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PantallaRegistroPlatoAvanzado(plato: plato),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => foodProvider.eliminarPlato(plato.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Registros del día:", style: TextStyle(fontWeight: FontWeight.bold)),
          TextButton.icon(
            onPressed: () => _seleccionarFecha(context),
            icon: const Icon(Icons.calendar_today),
            label: Text(DateFormat('dd MMMM yyyy', 'es_ES').format(_fechaSeleccionada)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(FoodProvider provider) {
    final hoy = DateTime.now();
    final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final inicioMes = DateTime(hoy.year, hoy.month, 1);
    
    final caloriasHoy = provider.getCaloriasConsumidasPorFecha(fechaHoy);

    double caloriasSemana = 0;
    for (int i = 0; i < 7; i++) {
      final fecha = DateTime.now().subtract(Duration(days: i));
      caloriasSemana += provider.getCaloriasConsumidasPorFecha(fecha);
    }

    final caloriasMes = provider.allPlatos
      .where((p) => !p.fecha.isBefore(inicioMes))
      .fold<double>(0, (sum, p) => sum + p.totalCalorias);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryCard("Hoy", "${caloriasHoy.toStringAsFixed(0)} kcal"),
          _summaryCard("Semana", "${caloriasSemana.toStringAsFixed(0)} kcal"),
          _summaryCard("Mes", "${caloriasMes.toStringAsFixed(0)} kcal"),
        ],
      ),
    );
  }

  Widget _summaryCard(String titulo, String valor) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(valor),
            ],
          ),
        ),
      ),
    );
  }
}
