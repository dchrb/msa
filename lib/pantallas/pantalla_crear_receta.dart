import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/models/alimento.dart';
import 'package:msa/providers/receta_provider.dart';
import 'package:msa/providers/racha_provider.dart';
import 'package:msa/providers/insignia_provider.dart';

class PantallaCrearReceta extends StatefulWidget {
  const PantallaCrearReceta({super.key});

  @override
  State<PantallaCrearReceta> createState() => _PantallaCrearRecetaState();
}

class _PantallaCrearRecetaState extends State<PantallaCrearReceta> {
  final _nombreRecetaController = TextEditingController();
  final _procedimientoController = TextEditingController();
  final List<Alimento> _ingredientesAgregados = [];

  final double _totalCalorias = 0.0;
  final double _totalProteinas = 0.0;
  final double _totalCarbs = 0.0;
  final double _totalGrasas = 0.0;

  @override
  void dispose() {
    _nombreRecetaController.dispose();
    _procedimientoController.dispose();
    super.dispose();
  }

  void _guardarReceta() {
    final nombre = _nombreRecetaController.text.trim();
    final procedimiento = _procedimientoController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, dale un nombre a tu receta.')));
      return;
    }
    if (procedimiento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, describe los pasos de la receta.')));
      return;
    }

    context.read<RecetaProvider>().agregarReceta(
      nombre: nombre,
      alimentos: _ingredientesAgregados,
      pasos: [procedimiento], 
    );

    final rachaProvider = context.read<RachaProvider>();
    final insigniaProvider = context.read<InsigniaProvider>();
    rachaProvider.actualizarRacha('re_racha_crear_receta', true);
    insigniaProvider.otorgarInsignia('re_ins_primera_receta');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receta "$nombre" guardada con éxito.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Receta'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _guardarReceta, tooltip: 'Guardar Receta')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreRecetaController,
              decoration: const InputDecoration(labelText: 'Nombre de la Receta', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _procedimientoController,
              decoration: const InputDecoration(
                labelText: 'Pasos de la Preparación',
                hintText: '1. Cortar las verduras...\n2. Sofreír el ajo...\n3. ...',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 24),
            const Text('Ingredientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildListaIngredientes(),
            const SizedBox(height: 24),
            _buildTotalesNutricionales(),
          ],
        ),
      ),
    );
  }

  Widget _buildListaIngredientes() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      height: 100,
      child: const Center(child: Text('La funcionalidad para añadir ingredientes se implementará aquí.')),
    );
  }

  Widget _buildTotalesNutricionales() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Totales Nutricionales (Estimado)", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text("Calorías: ${_totalCalorias.toStringAsFixed(0)} kcal"),
            Text("Proteínas: ${_totalProteinas.toStringAsFixed(1)} g"),
            Text("Carbohidratos: ${_totalCarbs.toStringAsFixed(1)} g"),
            Text("Grasas: ${_totalGrasas.toStringAsFixed(1)} g"),
          ],
        ),
      ),
    );
  }
}
