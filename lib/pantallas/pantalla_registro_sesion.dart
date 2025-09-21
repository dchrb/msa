import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msa/models/ejercicio.dart';
import 'package:msa/models/sesion_entrenamiento.dart';
import 'package:msa/pantallas/pantalla_biblioteca_ejercicios.dart';
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:msa/models/detalle_ejercicio.dart';
import 'package:msa/models/serie.dart';

class PantallaRegistroSesion extends StatefulWidget {
  final SesionEntrenamiento? sesionAEditar;

  const PantallaRegistroSesion({super.key, this.sesionAEditar});

  @override
  State<PantallaRegistroSesion> createState() => _PantallaRegistroSesionState();
}

class _PantallaRegistroSesionState extends State<PantallaRegistroSesion> {
  final _nombreController = TextEditingController();
  DateTime _fechaSeleccionada = DateTime.now();
  final List<DetalleEjercicio> _detallesEjercicio = [];
  final Map<String, Ejercicio> _ejerciciosAgregadosMap = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.sesionAEditar != null) {
      _isEditing = true;
      final sesion = widget.sesionAEditar!;
      _nombreController.text = sesion.nombre;
      _fechaSeleccionada = sesion.fecha;
      _detallesEjercicio.addAll(sesion.detalles);

      final provider = context.read<EntrenamientoProvider>();
      for (var detalle in sesion.detalles) {
        final ejercicio = provider.getEjercicioPorId(detalle.ejercicioId);
        if (ejercicio != null) {
          _ejerciciosAgregadosMap[ejercicio.id] = ejercicio;
        }
      }
    } else {
      _nombreController.text = 'Mi Entrenamiento';
    }
  }

  void _guardarSesion() {
    if (_nombreController.text.isEmpty || _detallesEjercicio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, pon un nombre y añade al menos un ejercicio.')),
      );
      return;
    }

    final entrenamientoProvider = context.read<EntrenamientoProvider>();
    late SesionEntrenamiento sesionGuardada;
    
    if (_isEditing) {
      sesionGuardada = SesionEntrenamiento(
        id: widget.sesionAEditar!.id,
        nombre: _nombreController.text,
        fecha: _fechaSeleccionada,
        detalles: _detallesEjercicio,
      );
      entrenamientoProvider.editarSesion(sesionGuardada);
    } else {
      sesionGuardada = SesionEntrenamiento(
        id: const Uuid().v4(),
        nombre: _nombreController.text,
        fecha: _fechaSeleccionada,
        detalles: _detallesEjercicio,
      );
      entrenamientoProvider.agregarSesion(sesionGuardada);
    }

    // -- DISPARAR LÓGICA DE GAMIFICACIÓN --
    final insigniaProvider = context.read<InsigniaProvider>();
    insigniaProvider.verificarInsigniasPorActividad(sesionGuardada);
    // ----------------------------------------

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Entrenamiento ${_isEditing ? 'actualizado' : 'guardado'}!')),
    );

    if (_isEditing) {
      Navigator.of(context)..pop()..pop(); // Vuelve dos pantallas atrás
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _navegarYSeleccionarEjercicio() async {
    final Ejercicio? ejercicioSeleccionado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PantallaBibliotecaEjercicios(isSelectionMode: true),
      ),
    );

    if (ejercicioSeleccionado != null && mounted) {
      setState(() {
        final nuevoDetalle = DetalleEjercicio(
          ejercicioId: ejercicioSeleccionado.id,
          series: [],
          duracionMinutos: null,
          distanciaKm: null,
          repeticionesSinPeso: null,
        );
        _detallesEjercicio.add(nuevoDetalle);
        _ejerciciosAgregadosMap[ejercicioSeleccionado.id] = ejercicioSeleccionado;
      });
    }
  }

  void _mostrarDialogoAnadirSerie(int ejercicioIndex) {
    final repsController = TextEditingController();
    final pesoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Serie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Repeticiones'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pesoController,
              decoration: const InputDecoration(labelText: 'Peso (kg, opcional)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final reps = int.tryParse(repsController.text);
              final peso = double.tryParse(pesoController.text);

              if (reps != null && reps > 0) {
                setState(() {
                  _detallesEjercicio[ejercicioIndex].series.add(Serie(repeticiones: reps, pesoKg: peso));
                });
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, introduce un número de repeticiones válido.')),
                );
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAnadirCardio(int ejercicioIndex) {
    final repsController = TextEditingController(text: _detallesEjercicio[ejercicioIndex].repeticionesSinPeso?.toString() ?? '');
    final duracionController = TextEditingController(text: _detallesEjercicio[ejercicioIndex].duracionMinutos?.toString() ?? '');
    final distanciaController = TextEditingController(text: _detallesEjercicio[ejercicioIndex].distanciaKm?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Cardio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Repeticiones (opcional)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: duracionController,
              decoration: const InputDecoration(labelText: 'Duración (minutos, opcional)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: distanciaController,
              decoration: const InputDecoration(labelText: 'Distancia (km, opcional)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final reps = int.tryParse(repsController.text);
              final duracion = double.tryParse(duracionController.text);
              final distancia = double.tryParse(distanciaController.text);
              
              if ((reps != null && reps >= 0) || (duracion != null && duracion >= 0) || (distancia != null && distancia >= 0)) {
                setState(() {
                  _detallesEjercicio[ejercicioIndex].repeticionesSinPeso = reps;
                  _detallesEjercicio[ejercicioIndex].duracionMinutos = duracion;
                  _detallesEjercicio[ejercicioIndex].distanciaKm = distancia;
                });
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, introduce al menos un valor válido.')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Entrenamiento' : 'Registrar Entrenamiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarSesion,
            tooltip: 'Guardar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalles de la Sesión', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Entrenamiento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Fecha: ${DateFormat('dd/MM/yyyy', 'es_ES').format(_fechaSeleccionada)}'),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _fechaSeleccionada,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      locale: const Locale('es', 'ES'),
                    );
                    if (picked != null && picked != _fechaSeleccionada) {
                      setState(() {
                        _fechaSeleccionada = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 32),
            Text('Ejercicios', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_detallesEjercicio.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Añade ejercicios a tu sesión con el botón de abajo.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _detallesEjercicio.length,
                itemBuilder: (context, index) {
                  final detalle = _detallesEjercicio[index];
                  final ejercicio = _ejerciciosAgregadosMap[detalle.ejercicioId]!;
                  return _buildEjercicioCard(detalle, ejercicio, index);
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarYSeleccionarEjercicio,
        label: const Text('Añadir Ejercicio'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEjercicioCard(DetalleEjercicio detalle, Ejercicio ejercicio, int ejercicioIndex) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    ejercicio.nombre,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _detallesEjercicio.removeAt(ejercicioIndex);
                      _ejerciciosAgregadosMap.remove(ejercicio.id);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (ejercicio.tipo == TipoEjercicio.fuerza) ...[
              if (detalle.series.isEmpty)
                const Text('Aún no has añadido series. Añade una con el botón de abajo.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: detalle.series.length,
                  itemBuilder: (context, serieIndex) {
                    final serie = detalle.series[serieIndex];
                    return ListTile(
                      title: Text(
                        'Serie ${serieIndex + 1}: ${serie.repeticiones} reps${serie.pesoKg != null ? ' x ${serie.pesoKg} kg' : ''}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _detallesEjercicio[ejercicioIndex].series.removeAt(serieIndex);
                          });
                        },
                      ),
                    );
                  },
                ),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Añadir Serie'),
                onPressed: () {
                  _mostrarDialogoAnadirSerie(ejercicioIndex);
                },
              ),
            ] else if (ejercicio.tipo == TipoEjercicio.cardio) ...[
              Text('Repeticiones: ${detalle.repeticionesSinPeso ?? 0}'),
              Text('Duración: ${detalle.duracionMinutos ?? 0} minutos'),
              Text('Distancia: ${detalle.distanciaKm ?? 0} km'),
              TextButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Registrar Cardio'),
                onPressed: () {
                  _mostrarDialogoAnadirCardio(ejercicioIndex);
                },
              ),
            ] else ...[
              const Text('Ejercicio de flexibilidad, no requiere registro numérico.')
            ],
          ],
        ),
      ),
    );
  }
}
