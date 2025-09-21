import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/models/plato.dart';
import 'package:msa/models/alimento.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:msa/pantallas/pantalla_mis_alimentos.dart';
import 'package:uuid/uuid.dart';

class PantallaRegistroPlatoAvanzado extends StatefulWidget {
  final Plato? plato; 
  final TipoPlato? tipoPlatoInicial;

  const PantallaRegistroPlatoAvanzado({super.key, this.plato, this.tipoPlatoInicial});

  @override
  State<PantallaRegistroPlatoAvanzado> createState() => _PantallaRegistroPlatoAvanzadoState();
}

class _PantallaRegistroPlatoAvanzadoState extends State<PantallaRegistroPlatoAvanzado> {
  final _formKey = GlobalKey<FormState>();
  late Plato _platoActual;
  bool _isEdit = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _isEdit = widget.plato != null;
    if (_isEdit) {
      _platoActual = widget.plato!;
    } else {
      _platoActual = Plato(
        id: _uuid.v4(),
        tipo: widget.tipoPlatoInicial ?? TipoPlato.desayuno,
        fecha: DateTime.now(),
        alimentos: [],
        totalCalorias: 0,
      );
    }
  }

  void _guardarPlato() {
    if (_platoActual.alimentos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade al menos un alimento al plato')),
      );
      return;
    }

    final foodProvider = context.read<FoodProvider>();
    if (_isEdit) {
      foodProvider.editarPlato(_platoActual);
    } else {
      foodProvider.agregarPlato(
        tipo: _platoActual.tipo,
        alimentos: _platoActual.alimentos,
        fecha: _platoActual.fecha,
      );
    }

    final insigniaProvider = context.read<InsigniaProvider>();
    insigniaProvider.verificarInsigniasPorRegistroDeComida(_platoActual);

    Navigator.of(context).pop(true);
  }

  void _mostrarDialogoAlimento([Alimento? alimentoExistente]) {
    final isEditingAlimento = alimentoExistente != null;
    final formAlimentoKey = GlobalKey<FormState>();
    final Alimento alimento = isEditingAlimento 
      ? Alimento.fromJson(alimentoExistente.toJson()) 
      : Alimento(id: _uuid.v4(), nombre: '', calorias: 0, proteinas: 0, carbohidratos: 0, grasas: 0);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditingAlimento ? 'Editar Alimento' : 'Añadir Alimento'),
          content: Form(
            key: formAlimentoKey,
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
                    onSaved: (value) => alimento.calorias = double.tryParse(value!) ?? 0.0,
                  ),
                  // Campos para Proteínas, Carbohidratos, Grasas...
                  TextFormField(
                    initialValue: alimento.proteinas.toString(),
                    decoration: const InputDecoration(labelText: 'Proteínas (g)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => alimento.proteinas = double.tryParse(value!) ?? 0.0,
                  ),
                  TextFormField(
                    initialValue: alimento.carbohidratos.toString(),
                    decoration: const InputDecoration(labelText: 'Carbohidratos (g)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => alimento.carbohidratos = double.tryParse(value!) ?? 0.0,
                  ),
                  TextFormField(
                    initialValue: alimento.grasas.toString(),
                    decoration: const InputDecoration(labelText: 'Grasas (g)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => alimento.grasas = double.tryParse(value!) ?? 0.0,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (formAlimentoKey.currentState!.validate()) {
                  formAlimentoKey.currentState!.save();
                  setState(() {
                    if (isEditingAlimento) {
                      final index = _platoActual.alimentos.indexWhere((a) => a.id == alimento.id);
                      if (index != -1) {
                        _platoActual.alimentos[index] = alimento;
                      }
                    } else {
                      _platoActual.alimentos.add(alimento);
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _seleccionarAlimentoGuardado() async {
    final Alimento? alimentoSeleccionado = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PantallaMisAlimentos(),
      ),
    );

    if (alimentoSeleccionado != null) {
      setState(() {
        _platoActual.alimentos.add(alimentoSeleccionado);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Plato' : 'Registrar Plato'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _guardarPlato)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<TipoPlato>(
                initialValue: _platoActual.tipo,
                items: TipoPlato.values
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo.toString().split('.').last)))
                    .toList(),
                onChanged: (value) => setState(() => _platoActual.tipo = value!),
                decoration: const InputDecoration(labelText: 'Tipo de Comida'),
              ),
              ListTile(
                title: Text("Fecha: ${MaterialLocalizations.of(context).formatShortDate(_platoActual.fecha)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _platoActual.fecha,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _platoActual.fecha) {
                    setState(() => _platoActual.fecha = picked);
                  }
                },
              ),
              const SizedBox(height: 20),
              Text('Alimentos', style: Theme.of(context).textTheme.titleLarge),
              Expanded(
                child: ListView.builder(
                  itemCount: _platoActual.alimentos.length,
                  itemBuilder: (context, index) {
                    final alimento = _platoActual.alimentos[index];
                    return ListTile(
                      title: Text(alimento.nombre),
                      subtitle: Text('${alimento.calorias.toStringAsFixed(1)} kcal'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _mostrarDialogoAlimento(alimento)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _platoActual.alimentos.removeAt(index)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _seleccionarAlimentoGuardado,
            label: const Text('Desde Mis Alimentos'),
            icon: const Icon(Icons.storage),
            heroTag: 'select_food',
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () => _mostrarDialogoAlimento(),
            label: const Text('Añadir Nuevo'),
            icon: const Icon(Icons.add),
            heroTag: 'add_food',
          ),
        ],
      ),
    );
  }
}
