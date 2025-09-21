// lib/widgets/formulario_registro_alimento.dart

import 'package:flutter/material.dart';
import 'package:msa/models/alimento.dart';
import 'package:uuid/uuid.dart';

class FormularioRegistroAlimento extends StatefulWidget {
  final Function(Alimento)? onSave;
  final Alimento? alimentoAEditar;

  const FormularioRegistroAlimento({
    super.key,
    this.onSave,
    this.alimentoAEditar,
  });

  @override
  State<FormularioRegistroAlimento> createState() =>
      _FormularioRegistroAlimentoState();
}

class _FormularioRegistroAlimentoState
    extends State<FormularioRegistroAlimento> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _caloriasController = TextEditingController();
  final _proteinasController = TextEditingController();
  final _carbohidratosController = TextEditingController();
  final _grasasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.alimentoAEditar != null) {
      _nombreController.text = widget.alimentoAEditar!.nombre;
      _caloriasController.text = widget.alimentoAEditar!.calorias.toString();
      _proteinasController.text = widget.alimentoAEditar!.proteinas.toString();
      _carbohidratosController.text =
          widget.alimentoAEditar!.carbohidratos.toString();
      _grasasController.text = widget.alimentoAEditar!.grasas.toString();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _caloriasController.dispose();
    _proteinasController.dispose();
    _carbohidratosController.dispose();
    _grasasController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text.trim();
      final calorias = double.tryParse(_caloriasController.text);
      final proteinas = double.tryParse(_proteinasController.text) ?? 0.0;
      final carbohidratos = double.tryParse(_carbohidratosController.text) ?? 0.0;
      final grasas = double.tryParse(_grasasController.text) ?? 0.0;

      if (nombre.isEmpty || calorias == null || calorias <= 0) {
        return;
      }

      final nuevoAlimento = Alimento(
        id: widget.alimentoAEditar?.id ?? const Uuid().v4(),
        nombre: nombre,
        calorias: calorias,
        proteinas: proteinas,
        carbohidratos: carbohidratos,
        grasas: grasas,
        porcionGramos: 100,
        esManual: true,
      );

      widget.onSave?.call(nuevoAlimento);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.alimentoAEditar != null
            ? 'Editar Alimento'
            : 'Añadir Alimento Manual',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del alimento'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, introduce un nombre.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriasController,
                decoration:
                    const InputDecoration(labelText: 'Calorías por 100g'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null ||
                      double.tryParse(value)! <= 0) {
                    return 'Introduce un valor válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _proteinasController,
                decoration: const InputDecoration(labelText: 'Proteínas (g)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carbohidratosController,
                decoration: const InputDecoration(labelText: 'Carbohidratos (g)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _grasasController,
                decoration: const InputDecoration(labelText: 'Grasas (g)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}