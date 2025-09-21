import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/models/alimento.dart';
import 'package:uuid/uuid.dart';

class PantallaMisAlimentos extends StatefulWidget {
  const PantallaMisAlimentos({super.key});

  @override
  State<PantallaMisAlimentos> createState() => _PantallaMisAlimentosState();
}

class _PantallaMisAlimentosState extends State<PantallaMisAlimentos> {
  final _uuid = const Uuid();

  void _mostrarDialogoAlimento([Alimento? alimentoExistente]) {
    final formKey = GlobalKey<FormState>();
    Alimento alimento = alimentoExistente ?? Alimento(id: _uuid.v4(), nombre: '', calorias: 0, carbohidratos: 0, proteinas: 0, grasas: 0);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(alimentoExistente == null ? 'Añadir Alimento' : 'Editar Alimento'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: alimento.nombre,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    onSaved: (value) => alimento.nombre = value!,
                  ),
                  TextFormField(
                    initialValue: alimento.calorias.toString(),
                    decoration: const InputDecoration(labelText: 'Calorías'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                    onSaved: (value) => alimento.calorias = double.parse(value!),
                  ),
                   TextFormField(
                    initialValue: alimento.proteinas.toString(),
                    decoration: const InputDecoration(labelText: 'Proteínas (g)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => alimento.proteinas = double.tryParse(value!) ?? 0,
                  ),
                  TextFormField(
                    initialValue: alimento.carbohidratos.toString(),
                    decoration: const InputDecoration(labelText: 'Carbohidratos (g)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => alimento.carbohidratos = double.tryParse(value!) ?? 0,
                  ),
                  TextFormField(
                    initialValue: alimento.grasas.toString(),
                    decoration: const InputDecoration(labelText: 'Grasas (g)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => alimento.grasas = double.tryParse(value!) ?? 0,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final provider = context.read<FoodProvider>();
                  if (alimentoExistente != null) {
                    // Lógica para editar (si es necesario en el futuro)
                  } else {
                    provider.addAlimentoManual(alimento);
                  }
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final alimentos = foodProvider.alimentosManuales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Alimentos Personalizados'),
      ),
      body: alimentos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aquí puedes guardar alimentos que no encuentres en la búsqueda para reutilizarlos fácilmente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              itemCount: alimentos.length,
              itemBuilder: (ctx, index) {
                final alimento = alimentos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(alimento.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${alimento.calorias.toStringAsFixed(0)} kcal'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                onPressed: () => _mostrarDialogoAlimento(alimento),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  // TODO: Implementar removeAlimentoManual en FoodProvider
                                  // foodProvider.removeAlimentoManual(alimento.id);
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _macroInfo('Proteínas', alimento.proteinas, Colors.orange),
                              _macroInfo('Carbs', alimento.carbohidratos, Colors.blue),
                              _macroInfo('Grasas', alimento.grasas, Colors.purple),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoAlimento(),
        label: const Text('Añadir Alimento'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _macroInfo(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          '${value.toStringAsFixed(1)}g',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
        ),
      ],
    );
  }
}
