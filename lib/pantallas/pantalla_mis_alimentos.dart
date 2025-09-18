// lib/pantallas/pantalla_mis_alimentos.dart

import 'package:flutter/material.dart';
import 'package:msa/models/alimento.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:provider/provider.dart';
import 'package:msa/widgets/formulario_registro_alimento.dart';

class PantallaMisAlimentos extends StatefulWidget {
  const PantallaMisAlimentos({super.key});

  @override
  State<PantallaMisAlimentos> createState() => _PantallaMisAlimentosState();
}

class _PantallaMisAlimentosState extends State<PantallaMisAlimentos> {
  void _mostrarDialogoAnadirAlimento() {
    showDialog(
      context: context,
      builder: (ctx) => FormularioRegistroAlimento(
        onSave: (nuevoAlimento) {
          context.read<FoodProvider>().agregarAlimentoManual(nuevoAlimento);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${nuevoAlimento.nombre} guardado.')),
          );
        },
      ),
    );
  }

  void _mostrarDialogoEditarAlimento(Alimento alimentoAEditar) {
    showDialog(
      context: context,
      builder: (ctx) => FormularioRegistroAlimento(
        alimentoAEditar: alimentoAEditar,
        onSave: (alimentoActualizado) {
          context
              .read<FoodProvider>()
              .agregarAlimentoManual(alimentoActualizado);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${alimentoActualizado.nombre} actualizado.')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Alimentos'),
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          final alimentos = foodProvider.alimentosManuales;
          if (alimentos.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has guardado alimentos.\nUsa el botón "+" para añadir uno.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: alimentos.length,
            itemBuilder: (context, index) {
              final alimento = alimentos[index];
              return Dismissible(
                key: Key(alimento.id),
                direction: DismissDirection.endToStart,
                background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (direction) {
                  foodProvider.eliminarAlimentoManual(alimento.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${alimento.nombre} eliminado.')));
                },
                child: ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: Text(alimento.nombre),
                  subtitle: Text(
                      '${alimento.calorias.toStringAsFixed(0)} kcal por 100g'),
                  onTap: () => _mostrarDialogoEditarAlimento(alimento),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAnadirAlimento,
        child: const Icon(Icons.add),
      ),
    );
  }
}