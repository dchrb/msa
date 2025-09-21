
// lib/pantallas/pantalla_biblioteca_ejercicios.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:msa/models/ejercicio.dart';

class PantallaBibliotecaEjercicios extends StatelessWidget {
  final bool isSelectionMode;

  const PantallaBibliotecaEjercicios({
    super.key,
    this.isSelectionMode = false,
  });

  IconData _getIconForTipo(TipoEjercicio tipo) {
    switch (tipo) {
      case TipoEjercicio.fuerza:
        return Icons.fitness_center;
      case TipoEjercicio.cardio:
        return Icons.directions_run;
      case TipoEjercicio.flexibilidad:
        return Icons.self_improvement;
      default:
        return Icons.help_outline;
    }
  }

  void _mostrarDialogoAnadirOEditarEjercicio(BuildContext context, {Ejercicio? ejercicioAEditar}) {
    final bool esEdicion = ejercicioAEditar != null;
    final nombreController = TextEditingController(text: esEdicion ? ejercicioAEditar.nombre : '');
    final musculoController = TextEditingController(text: esEdicion ? (ejercicioAEditar.musculoPrincipal ?? '') : '');
    TipoEjercicio tipoSeleccionado = esEdicion ? ejercicioAEditar.tipo : TipoEjercicio.fuerza;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(esEdicion ? 'Editar Ejercicio' : 'Añadir Nuevo Ejercicio'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre del Ejercicio'),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TipoEjercicio>(
                      initialValue: tipoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Tipo de Ejercicio'),
                      items: TipoEjercicio.values.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setDialogState(() {
                            tipoSeleccionado = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: musculoController,
                      decoration: const InputDecoration(labelText: 'Músculo Principal (Opcional)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                ElevatedButton(
                  child: Text(esEdicion ? 'Guardar' : 'Añadir'),
                  onPressed: () {
                    final nombre = nombreController.text;
                    final musculo = musculoController.text;
                    final provider = context.read<EntrenamientoProvider>();

                    if (nombre.isNotEmpty) {
                      if (!esEdicion && provider.existeEjercicio(nombre)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ya existe un ejercicio con este nombre.')),
                        );
                        return;
                      }

                      if (esEdicion) {
                        final ejercicioActualizado = Ejercicio(
                          id: ejercicioAEditar.id,
                          nombre: nombre,
                          tipo: tipoSeleccionado,
                          musculoPrincipal: musculo.isNotEmpty ? musculo : null,
                        );
                        provider.editarEjercicio(ejercicioActualizado);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ejercicio actualizado.')),
                        );
                      } else {
                        final nuevoEjercicio = Ejercicio(
                          id: const Uuid().v4(),
                          nombre: nombre,
                          tipo: tipoSeleccionado,
                          musculoPrincipal: musculo.isNotEmpty ? musculo : null,
                        );
                        provider.agregarEjercicio(nuevoEjercicio);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ejercicio añadido.')),
                        );
                      }
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de Ejercicios'),
        leading: isSelectionMode ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ) : null,
      ),
      body: Consumer<EntrenamientoProvider>(
        builder: (context, entrenamientoProvider, child) {
          if (!entrenamientoProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final ejercicios = entrenamientoProvider.ejercicios;

          if (ejercicios.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Tu biblioteca está vacía.', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('¡Añade tu primer ejercicio con el botón de abajo!', textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    Icon(Icons.arrow_downward, size: 40, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: ejercicios.length,
            itemBuilder: (context, index) {
              final ejercicio = ejercicios[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: isSelectionMode
                    ? ListTile(
                        leading: Icon(
                          _getIconForTipo(ejercicio.tipo),
                          color: Theme.of(context).colorScheme.primary,
                          size: 40,
                        ),
                        title: Text(
                          ejercicio.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(ejercicio.musculoPrincipal ?? 'General'),
                        onTap: () => Navigator.of(context).pop(ejercicio),
                      )
                    : Dismissible(
                        key: Key(ejercicio.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirmar"),
                                content: const Text(
                                    "¿Estás seguro de que quieres eliminar este ejercicio? Esta acción no se puede deshacer."),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("CANCELAR"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("ELIMINAR",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          entrenamientoProvider.eliminarEjercicio(ejercicio.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${ejercicio.nombre} eliminado')),
                          );
                        },
                        child: ListTile(
                          leading: Icon(
                            _getIconForTipo(ejercicio.tipo),
                            color: Theme.of(context).colorScheme.primary,
                            size: 40,
                          ),
                          title: Text(
                            ejercicio.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(ejercicio.musculoPrincipal ?? 'General'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _mostrarDialogoAnadirOEditarEjercicio(
                                  context, ejercicioAEditar: ejercicio);
                            },
                          ),
                        ),
                      ),
              );
            },
          );
        },
      ),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                _mostrarDialogoAnadirOEditarEjercicio(context);
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
