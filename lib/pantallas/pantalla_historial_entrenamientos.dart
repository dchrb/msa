// lib/pantallas/pantalla_historial_entrenamientos.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msa/pantallas/pantalla_detalle_sesion.dart';
import 'package:msa/pantallas/pantalla_registro_sesion.dart';
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:provider/provider.dart';

class PantallaHistorialEntrenamientos extends StatelessWidget {
  const PantallaHistorialEntrenamientos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // <-- LÍNEA AÑADIDA
        title: const Text('Historial de Entrenamientos'),
      ),
      body: Consumer<EntrenamientoProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final sesiones = provider.sesiones;

          return sesiones.isEmpty
              ? const Center(
                  child: Text(
                    'Aún no has registrado ningún entrenamiento.\n¡Empieza con el botón +!',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: sesiones.length,
                  itemBuilder: (context, index) {
                    final sesion = sesiones[index];
                    return Dismissible(
                      key: Key(sesion.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirmar"),
                              content: const Text("¿Estás seguro de que quieres eliminar esta sesión?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text("CANCELAR"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        provider.eliminarSesion(sesion.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${sesion.nombre} eliminado')),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(sesion.nombre),
                          subtitle: Text(DateFormat('dd MMMM yyyy', 'es_ES').format(sesion.fecha)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PantallaDetalleSesion(sesion: sesion),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PantallaRegistroSesion()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}