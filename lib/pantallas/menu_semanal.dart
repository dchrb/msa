// lib/pantallas/menu_semanal.dart

import 'package:flutter/material.dart';
import 'package:msa/models/plato.dart'; // Para usar TipoPlato
import 'package:msa/providers/dieta_provider.dart';
import 'package:msa/models/comida_planificada.dart'; // Importamos el nuevo modelo
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class MenuSemanal extends StatelessWidget {
  const MenuSemanal({super.key});

  @override
  Widget build(BuildContext context) {
    final dietaProvider = context.watch<DietaProvider>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (int i = 1; i <= 7; i++) ...[
              _buildDiaSemanal(context, i, dietaProvider),
              if (i < 7) const Divider(height: 32, thickness: 1),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiaSemanal(
      BuildContext context, int dia, DietaProvider dietaProvider) {
    final nombreDia = _getNombreDia(dia);
    final comidas = dietaProvider.menuSemanal[dia] ?? [];

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(nombreDia, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      children: [
        if (comidas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No hay comidas planificadas para este día.'),
          )
        else
          ...comidas.map((comida) => _buildComidaPlanificadaListTile(context, comida, dia, dietaProvider)).toList(),
        ListTile(
          title: const Text('Añadir comida', style: TextStyle(color: Colors.blue)),
          leading: const Icon(Icons.add, color: Colors.blue),
          onTap: () => _mostrarDialogoAnadirComida(context, dia, dietaProvider),
        ),
      ],
    );
  }

  Widget _buildComidaPlanificadaListTile(BuildContext context, ComidaPlanificada comida, int dia, DietaProvider dietaProvider) {
    return ListTile(
      title: Text(comida.tipo.toString().split('.').last.toUpperCase()),
      subtitle: Text(comida.nombre),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => dietaProvider.eliminarComidaPlanificada(dia, comida),
      ),
    );
  }

  void _mostrarDialogoAnadirComida(BuildContext context, int dia, DietaProvider dietaProvider) {
    final nombreController = TextEditingController();
    TipoPlato tipoSeleccionado = TipoPlato.desayuno;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Añadir comida al plan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre de la comida'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TipoPlato>(
                    value: tipoSeleccionado,
                    items: TipoPlato.values.map((t) => DropdownMenuItem(value: t, child: Text(t.toString().split('.').last))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          tipoSeleccionado = v;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Tipo de Comida'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    if (nombreController.text.isNotEmpty) {
                      final nuevaComida = ComidaPlanificada(
                        id: const Uuid().v4(),
                        nombre: nombreController.text,
                        tipo: tipoSeleccionado,
                      );
                      dietaProvider.agregarComidaPlanificada(dia, nuevaComida);
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getNombreDia(int dia) {
    switch (dia) {
      case 1: return 'Lunes';
      case 2: return 'Martes';
      case 3: return 'Miércoles';
      case 4: return 'Jueves';
      case 5: return 'Viernes';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return '';
    }
  }
}