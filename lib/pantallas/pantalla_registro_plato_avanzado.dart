// lib/pantallas/pantalla_registro_plato_avanzado.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/models/alimento.dart';
import 'package:msa/models/plato.dart';
import 'package:msa/providers/nutricion_provider.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:msa/providers/water_provider.dart';
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:msa/widgets/formulario_registro_alimento.dart';

class PantallaRegistroPlatoAvanzado extends StatefulWidget {
  const PantallaRegistroPlatoAvanzado({super.key});

  @override
  State<PantallaRegistroPlatoAvanzado> createState() => _PantallaRegistroPlatoAvanzadoState();
}

class _PantallaRegistroPlatoAvanzadoState extends State<PantallaRegistroPlatoAvanzado> {
  final _alimentoController = TextEditingController();
  final _cantidadController = TextEditingController(text: '100');
  final List<Alimento> _alimentosAgregados = [];
  TipoPlato _tipoSeleccionado = TipoPlato.almuerzo;
  
  double _totalCalorias = 0.0;
  double _totalProteinas = 0.0;
  double _totalCarbs = 0.0;
  double _totalGrasas = 0.0;
  
  Alimento? _alimentoSeleccionado;
  List<Alimento> _resultadosBusqueda = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _alimentoController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  void _calcularTotales() {
    _totalCalorias = _alimentosAgregados.fold(0.0, (sum, item) => sum + item.calorias);
    _totalProteinas = _alimentosAgregados.fold(0.0, (sum, item) => sum + item.proteinas);
    _totalCarbs = _alimentosAgregados.fold(0.0, (sum, item) => sum + item.carbohidratos);
    _totalGrasas = _alimentosAgregados.fold(0.0, (sum, item) => sum + item.grasas);
  }

  void _buscarAlimentos(String busqueda) async {
    final foodProvider = context.read<FoodProvider>();
    final nutricionProvider = context.read<NutricionProvider>();

    final alimentosManuales = foodProvider.alimentosManuales
        .where((alimento) => alimento.nombre.toLowerCase().contains(busqueda.toLowerCase()))
        .toList();

    setState(() {
      _resultadosBusqueda = alimentosManuales;
    });

    await nutricionProvider.buscarAlimentos(busqueda);
    setState(() {
      _resultadosBusqueda.addAll(nutricionProvider.alimentosEncontrados);
    });
  }

  Future<void> _agregarAlimentoSeleccionado() async {
    if (_alimentoSeleccionado == null || _cantidadController.text.isEmpty) {
      return;
    }

    final cantidad = double.tryParse(_cantidadController.text);
    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa una cantidad válida.')),
      );
      return;
    }
    
    Alimento? infoNutricional;
    if (_alimentoSeleccionado!.esManual) {
      infoNutricional = Alimento(
        nombre: _alimentoSeleccionado!.nombre,
        calorias: (_alimentoSeleccionado!.calorias / 100) * cantidad,
        proteinas: (_alimentoSeleccionado!.proteinas / 100) * cantidad,
        carbohidratos: (_alimentoSeleccionado!.carbohidratos / 100) * cantidad,
        grasas: (_alimentoSeleccionado!.grasas / 100) * cantidad,
        porcionGramos: cantidad,
        esManual: true,
        idApi: _alimentoSeleccionado!.idApi,
      );
    } else {
      final nutricionProvider = context.read<NutricionProvider>();
      infoNutricional = await nutricionProvider.getInfoNutricional(_alimentoSeleccionado!.idApi!, cantidad);
    }

    if (infoNutricional != null) {
      setState(() {
        _alimentosAgregados.add(infoNutricional!);
        _calcularTotales();
        _alimentoController.clear();
        _cantidadController.text = '100';
        _alimentoSeleccionado = null;
        _resultadosBusqueda.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener la información nutricional.')),
      );
    }
  }

  void _guardarPlato() {
    if (_alimentosAgregados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, agrega al menos un alimento.')),
      );
      return;
    }
    
    final foodProvider = context.read<FoodProvider>();
    final nuevoPlato = Plato(
      id: const Uuid().v4(),
      tipo: _tipoSeleccionado,
      fecha: DateTime.now(),
      alimentos: _alimentosAgregados,
      totalCalorias: _totalCalorias,
    );
    foodProvider.agregarPlato(nuevoPlato.tipo, nuevoPlato.alimentos, nuevoPlato.fecha);
    
    context.read<InsigniaProvider>().verificarHabitoTrio(
      context,
      context.read<WaterProvider>(),
      context.read<FoodProvider>(),
      context.read<EntrenamientoProvider>(),
    );
    
    Navigator.of(context).pop();
  }

  void _mostrarDialogoAnadirAlimento() {
    showDialog(
      context: context,
      builder: (ctx) => FormularioRegistroAlimento(
        onSave: (nuevoAlimento) {
          context.read<FoodProvider>().agregarAlimentoManual(nuevoAlimento);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('${nuevoAlimento.nombre} guardado.')),
          );
          // Refrescar la pantalla para que el nuevo alimento aparezca en la búsqueda
          setState(() {
            _alimentoController.text = nuevoAlimento.nombre;
            _buscarAlimentos(nuevoAlimento.nombre);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Comida Avanzado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarPlato,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBuscadorAlimentos(context),
            const SizedBox(height: 24),
            
            _buildListaAlimentos(),
            const SizedBox(height: 24),

            _buildTotalesNutricionales(),
            const SizedBox(height: 24),

            _buildSelectorTipoPlato(),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscadorAlimentos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _alimentoController,
                decoration: InputDecoration(
                  labelText: 'Buscar alimento',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      if (_alimentoController.text.isNotEmpty) {
                        _buscarAlimentos(_alimentoController.text);
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _buscarAlimentos(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Gramos',
                ),
              ),
            ),
          ],
        ),
        Consumer<NutricionProvider>(
          builder: (context, nutricionProvider, child) {
            if (nutricionProvider.isSearching) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_resultadosBusqueda.isNotEmpty) {
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _resultadosBusqueda.length,
                  itemBuilder: (context, index) {
                    final alimento = _resultadosBusqueda[index];
                    return ListTile(
                      leading: alimento.esManual ? const Icon(Icons.person) : null,
                      title: Text(alimento.nombre),
                      subtitle: Text('${alimento.calorias.toStringAsFixed(0)} kcal por 100g'),
                      onTap: () {
                        setState(() {
                          _alimentoSeleccionado = alimento;
                          _alimentoController.text = alimento.nombre;
                        });
                      },
                    );
                  },
                ),
              );
            }
            
            // Condición para mostrar el botón de agregar manualmente si no hay resultados
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  const Text('No se encontraron resultados. ¿Quieres añadirlo manualmente?', textAlign: TextAlign.center,),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir alimento manualmente'),
                    onPressed: _mostrarDialogoAnadirAlimento,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _alimentoSeleccionado != null ? _agregarAlimentoSeleccionado : null,
          child: const Text('Agregar al plato'),
        ),
      ],
    );
  }

  Widget _buildListaAlimentos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alimentos en tu plato (${_alimentosAgregados.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_alimentosAgregados.isEmpty)
          const Text('Aún no has agregado alimentos.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _alimentosAgregados.length,
            itemBuilder: (context, index) {
              final alimento = _alimentosAgregados[index];
              return ListTile(
                title: Text(alimento.nombre),
                subtitle: Text('${alimento.calorias.toStringAsFixed(0)} kcal'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _alimentosAgregados.removeAt(index);
                      _calcularTotales();
                    });
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTotalesNutricionales() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Totales Nutricionales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Calorías: ${_totalCalorias.toStringAsFixed(0)} kcal'),
            Text('Proteínas: ${_totalProteinas.toStringAsFixed(1)} g'),
            Text('Carbohidratos: ${_totalCarbs.toStringAsFixed(1)} g'),
            Text('Grasas: ${_totalGrasas.toStringAsFixed(1)} g'),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorTipoPlato() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo de Comida', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<TipoPlato>(
          value: _tipoSeleccionado,
          items: TipoPlato.values.map((tipo) {
            return DropdownMenuItem(
              value: tipo,
              child: Text(tipo.toString().split('.').last),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _tipoSeleccionado = value;
              });
            }
          },
        ),
      ],
    );
  }
}