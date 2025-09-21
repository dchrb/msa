import 'package:flutter/material.dart';
import 'package:msa/models/tipo_plato.dart';
import 'package:msa/providers/dieta_provider.dart';
import 'package:msa/models/comida_planificada.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:msa/providers/racha_provider.dart';
import 'package:provider/provider.dart';

class MenuSemanal extends StatelessWidget {
  const MenuSemanal({super.key});

  @override
  Widget build(BuildContext context) {
    final dietaProvider = context.watch<DietaProvider>();
    final menuSemanal = dietaProvider.menuSemanal;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (int i = 1; i <= 7; i++) ...[
              _buildDiaSemanal(context, i, menuSemanal[i] ?? []),
              if (i < 7) const Divider(height: 32, thickness: 1),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiaSemanal(BuildContext context, int dia, List<ComidaPlanificada> comidas) {
    final nombreDia = _getNombreDia(dia);
    
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      initiallyExpanded: dia == DateTime.now().weekday,
      title: Text(nombreDia, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      children: [
        if (comidas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No hay comidas planificadas para este día.'),
          )
        else
          ...comidas.map((comida) => _buildComidaPlanificadaListTile(context, comida)),
        ListTile(
          title: const Text('Añadir comida', style: TextStyle(color: Colors.blue)),
          leading: const Icon(Icons.add, color: Colors.blue),
          onTap: () => _mostrarDialogoAnadirComida(context, dia),
        ),
      ],
    );
  }

  Widget _buildComidaPlanificadaListTile(BuildContext context, ComidaPlanificada comida) {
    return ListTile(
      title: Text(comida.tipo.toString().split('.').last.toUpperCase()),
      subtitle: Text(comida.nombre),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          context.read<DietaProvider>().eliminarComidaPlanificada(comida.id);
        },
      ),
    );
  }

  void _mostrarDialogoAnadirComida(BuildContext context, int dia) {
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
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TipoPlato>(
                    initialValue: tipoSeleccionado,
                    items: TipoPlato.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.toString().split('.').last)
                      );
                    }).toList(),
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
                FilledButton(
                  onPressed: () async {
                    if (nombreController.text.isNotEmpty) {
                      final dietaProvider = context.read<DietaProvider>();
                      final rachaProvider = context.read<RachaProvider>();
                      final insigniaProvider = context.read<InsigniaProvider>();
                      
                      await dietaProvider.agregarComidaPlanificada(
                        dia,
                        nombreController.text,
                        tipoSeleccionado,
                      );
                      
                      // Insignia: Primer plan creado
                      insigniaProvider.otorgarInsignia('ps_ins_primer_plan');

                      // Racha: Semanas seguidas creando un plan
                      rachaProvider.actualizarRacha('ps_racha_plan_creado', true);
                      
                      // Insignia: Plan de la semana completado (1 comida por día)
                      final menu = dietaProvider.menuSemanal;
                      final diasConComida = menu.values.where((list) => list.isNotEmpty).length;
                      if (diasConComida >= 7) {
                          insigniaProvider.otorgarInsignia('ps_ins_plan_completo');
                      }

                      if (!ctx.mounted) return;
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
