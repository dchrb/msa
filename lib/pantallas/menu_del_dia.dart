// lib/pantallas/menu_del_dia.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msa/models/plato.dart';
import 'package:msa/providers/dieta_provider.dart';
import 'package:provider/provider.dart';
import 'package:msa/models/comida_planificada.dart';
import 'package:msa/pantallas/pantalla_registro_plato_avanzado.dart';

class MenuDelDia extends StatelessWidget {
  const MenuDelDia({super.key});

  @override
  Widget build(BuildContext context) {
    final dietaProvider = context.watch<DietaProvider>();
    final hoy = DateTime.now().weekday;
    final menuDeHoy = dietaProvider.getMenuDelDia(hoy);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Menú para hoy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (menuDeHoy.isEmpty)
            const Center(child: Text('No tienes comidas planeadas para hoy.'))
          else
            ...menuDeHoy.map((comida) => _buildComidaCard(context, comida)).toList(),
        ],
      ),
    );
  }

  Widget _buildComidaCard(BuildContext context, ComidaPlanificada comida) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: CheckboxListTile(
        title: Text(comida.tipo.toString().split('.').last.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(comida.nombre),
        value: comida.completado,
        onChanged: (bool? newValue) {
          context.read<DietaProvider>().marcarComidaComoCompletada(
              DateTime.now().weekday, comida.id, newValue ?? false);
          
          if (newValue == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('¡Comida completada! Ahora, registra las calorías.'),
                action: SnackBarAction(
                  label: 'Registrar',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PantallaRegistroPlatoAvanzado()),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}