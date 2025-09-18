import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:msa/models/alimento.dart';
import 'package:msa/models/plato.dart';
import 'package:msa/providers/food_provider.dart';

class RegistroComidas extends StatefulWidget {
  const RegistroComidas({super.key});

  @override
  State<RegistroComidas> createState() => _RegistroComidasState();
}

class _RegistroComidasState extends State<RegistroComidas> {
  final List<Alimento> _alimentos = [];
  TipoPlato _tipoPlato = TipoPlato.desayuno;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _caloriasController = TextEditingController();
  final TextEditingController _proteinasController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _grasasController = TextEditingController();
  final TextEditingController _porcionController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _caloriasController.dispose();
    _proteinasController.dispose();
    _carbsController.dispose();
    _grasasController.dispose();
    _porcionController.dispose();
    super.dispose();
  }

  void _agregarAlimento() {
    final nombre = _nombreController.text.trim();
    final calorias = double.tryParse(_caloriasController.text) ?? 0;
    final proteinas = double.tryParse(_proteinasController.text) ?? 0;
    final carbohidratos = double.tryParse(_carbsController.text) ?? 0;
    final grasas = double.tryParse(_grasasController.text) ?? 0;
    final porcion = double.tryParse(_porcionController.text) ?? 0;

    if (nombre.isEmpty) return;

    final nuevoAlimento = Alimento(
      nombre: nombre,
      calorias: calorias,
      proteinas: proteinas,
      carbohidratos: carbohidratos,
      grasas: grasas,
      porcionGramos: porcion,
    );

    setState(() {
      _alimentos.add(nuevoAlimento);
      _nombreController.clear();
      _caloriasController.clear();
      _proteinasController.clear();
      _carbsController.clear();
      _grasasController.clear();
      _porcionController.clear();
      // Ocultar el teclado
      FocusScope.of(context).unfocus();
    });
  }

  void _guardarPlato() {
    if (_alimentos.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes agregar al menos un alimento.")),
      );
      return;
    }

    final provider = context.read<FoodProvider>();
    // --- CORRECCIÓN 1: Añadimos la fecha actual ---
    provider.agregarPlato(_tipoPlato, List.from(_alimentos), DateTime.now());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Plato guardado correctamente")),
    );

    setState(() {
      _alimentos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // Ya no necesitamos un AppBar aquí porque esta pantalla estará dentro de un Tab
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<TipoPlato>(
              value: _tipoPlato,
              items: TipoPlato.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  // --- CORRECCIÓN 2: Usamos un método más seguro ---
                  child: Text(tipo.toString().split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: (tipo) {
                if (tipo != null) {
                  setState(() {
                    _tipoPlato = tipo;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Tipo de Comida',
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: _nombreController, decoration: const InputDecoration(labelText: "Nombre del alimento")),
                    TextField(controller: _caloriasController, decoration: const InputDecoration(labelText: "Calorías"), keyboardType: TextInputType.number),
                    TextField(controller: _proteinasController, decoration: const InputDecoration(labelText: "Proteínas (g)"), keyboardType: TextInputType.number),
                    TextField(controller: _carbsController, decoration: const InputDecoration(labelText: "Carbohidratos (g)"), keyboardType: TextInputType.number),
                    TextField(controller: _grasasController, decoration: const InputDecoration(labelText: "Grasas (g)"), keyboardType: TextInputType.number),
                    TextField(controller: _porcionController, decoration: const InputDecoration(labelText: "Porción (g)"), keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _agregarAlimento,
                      icon: const Icon(Icons.add),
                      label: const Text("Agregar alimento al plato"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.secondary,
                        foregroundColor: colors.onSecondary,
                      ),
                    ),
                    const Divider(height: 20),
                    const Text("Alimentos del Plato:", style: TextStyle(fontWeight: FontWeight.bold)),
                    if (_alimentos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Aún no has agregado alimentos."),
                      )
                    else
                      ..._alimentos.map((a) => ListTile(
                            title: Text(a.nombre),
                            subtitle: Text("${a.calorias} kcal"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _alimentos.remove(a);
                                });
                              },
                            ),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _guardarPlato,
              icon: const Icon(Icons.save),
              label: const Text("Guardar Plato"),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}