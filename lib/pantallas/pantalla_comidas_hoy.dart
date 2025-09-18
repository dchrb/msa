// lib/pantallas/pantalla_comidas_hoy.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/meta1_provider.dart';
import 'package:msa/pantallas/pantalla_mis_alimentos.dart';
import 'package:provider/provider.dart';
import 'package:msa/pantallas/pantalla_registro_plato_avanzado.dart';

class PantallaComidasHoy extends StatelessWidget {
  const PantallaComidasHoy({super.key});

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final metaProvider = context.watch<Meta1Provider>();

    if (metaProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final metaCalorias = metaProvider.metaCalorias;
    final caloriasConsumidas = foodProvider.getCaloriasPorFecha(DateTime.now());
    final caloriasRestantes = metaCalorias - caloriasConsumidas;
    final platosHoy = foodProvider.getPlatosPorFecha(DateTime.now());

    return Scaffold(
      body: Column(
        children: [
          _buildCalorieSummaryCard(
            meta: metaCalorias,
            consumidas: caloriasConsumidas,
            restantes: caloriasRestantes,
          ),
          const Divider(),
          Expanded(
            child: platosHoy.isEmpty
                ? const Center(child: Text("No has registrado comidas hoy."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: platosHoy.length,
                    itemBuilder: (context, index) {
                      final plato = platosHoy[index];
                      final nombresAlimentos = plato.alimentos.map((a) => a.nombre).join(', ');
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          title: Text(
                            plato.tipo.toString().split('.').last.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            nombresAlimentos,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${plato.totalCalorias.toStringAsFixed(0)} kcal",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(DateFormat.Hm().format(plato.fecha)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaMisAlimentos()),
              );
            },
            label: const Text('Mis Alimentos'),
            icon: const Icon(Icons.list_alt),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaRegistroPlatoAvanzado()),
              );
            },
            label: const Text('Registrar Comida'),
            icon: const Icon(Icons.restaurant_menu),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieSummaryCard({
    required int meta,
    required double consumidas,
    required double restantes,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryColumn("Meta", meta.toStringAsFixed(0)),
          const Text("-", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          _summaryColumn("Comidas", consumidas.toStringAsFixed(0)),
          const Text("=", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          _summaryColumn("Restantes", restantes.toStringAsFixed(0), isPrimary: true),
        ],
      ),
    );
  }

  Widget _summaryColumn(String titulo, String valor, {bool isPrimary = false}) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isPrimary ? Colors.teal : null,
          ),
        ),
        Text(titulo, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}