
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/models/plato.dart';
import 'package:msa/models/receta.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/receta_provider.dart';

class PantallaSeleccionarReceta extends StatelessWidget {
  final TipoPlato tipoPlato;

  const PantallaSeleccionarReceta({super.key, required this.tipoPlato});

  void _seleccionarReceta(BuildContext context, Receta receta) {
    final foodProvider = context.read<FoodProvider>();

    // Convierte la receta a un nuevo plato
    foodProvider.agregarPlato(
      tipo: tipoPlato,
      alimentos: receta.alimentos, // La lista de alimentos de la receta
      fecha: DateTime.now(),
    );

    // Muestra una confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${receta.nombre}" añadido a tu comida.'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Regresa a la pantalla anterior
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final recetaProvider = context.watch<RecetaProvider>();
    final recetas = recetaProvider.recetas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Receta'),
      ),
      body: recetas.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No tienes recetas guardadas. ¡Crea una primero desde la pantalla de "Mis Recetas"!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: recetas.length,
              itemBuilder: (context, index) {
                final receta = recetas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    title: Text(receta.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${receta.totalCalorias.toStringAsFixed(0)} kcal - P: ${receta.totalProteinas.toStringAsFixed(0)}g, C: ${receta.totalCarbohidratos.toStringAsFixed(0)}g, G: ${receta.totalGrasas.toStringAsFixed(0)}g',
                    ),
                    onTap: () => _seleccionarReceta(context, receta),
                  ),
                );
              },
            ),
    );
  }
}
