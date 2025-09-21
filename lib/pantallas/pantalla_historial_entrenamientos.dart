import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:msa/models/ejercicio.dart';
import 'package:msa/models/sesion_entrenamiento.dart';
import 'package:msa/pantallas/pantalla_detalle_sesion.dart';
import 'package:msa/pantallas/pantalla_registro_sesion.dart';
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:msa/widgets/seccion_recompensas.dart';

class PantallaHistorialEntrenamientos extends StatelessWidget {
  const PantallaHistorialEntrenamientos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EntrenamientoProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final sesiones = provider.sesiones;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEstadisticasGlobales(context, sesiones, provider),
                const SizedBox(height: 24),

                Text('Historial de Sesiones', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),

                sesiones.isEmpty
                    ? _buildEmptyState(context)
                    : _buildListaSesiones(context, sesiones, provider),
                
                const SizedBox(height: 16),
                const SeccionRecompensas(categoria: 'Actividad'),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PantallaRegistroSesion()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEstadisticasGlobales(BuildContext context, List<SesionEntrenamiento> sesiones, EntrenamientoProvider provider) {
    double volumenTotal = 0;
    double tiempoTotalCardio = 0;

    for (final sesion in sesiones) {
      tiempoTotalCardio += sesion.duracionMinutos ?? 0;

      for (final detalle in sesion.detalles) {
        final ejercicioBase = provider.getEjercicioPorId(detalle.ejercicioId);
        if (ejercicioBase == null) continue;

        if (ejercicioBase.tipo == TipoEjercicio.fuerza) {
          for (final serie in detalle.series) {
            volumenTotal += (serie.pesoKg ?? 0) * serie.repeticiones;
          }
        } else if (ejercicioBase.tipo == TipoEjercicio.cardio) {
          tiempoTotalCardio += detalle.duracionMinutos ?? 0;
        }
      }
    }

    final horasCardio = (tiempoTotalCardio / 60).floor();
    final minutosCardio = (tiempoTotalCardio % 60).round();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
             Text("Tus Estadísticas Totales", style: Theme.of(context).textTheme.titleLarge),
             const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat("Volumen Total", (volumenTotal / 1000).toStringAsFixed(1), "toneladas", Icons.fitness_center, context),
                _buildStat("Cardio Total", "${horasCardio}h ${minutosCardio}m", "", Icons.timer, context),
                _buildStat("Sesiones", sesiones.length.toString(), "", Icons.event_available, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, String unit, IconData icon, BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center,),
          if (unit.isNotEmpty) Text("($unit)", style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center,),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Text(
          'Aún no has registrado ningún entrenamiento.\n¡Empieza con el botón +!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildListaSesiones(BuildContext context, List<SesionEntrenamiento> sesiones, EntrenamientoProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
          confirmDismiss: (direction) => _confirmarEliminar(context),
          onDismissed: (direction) {
            provider.eliminarSesion(sesion.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sesión de ${sesion.nombre} eliminada')),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(sesion.nombre),
              subtitle: Text(DateFormat('dd MMMM yyyy, HH:mm', 'es_ES').format(sesion.fecha)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PantallaDetalleSesion(sesion: sesion)),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmarEliminar(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar"),
          content: const Text("¿Estás seguro de que quieres eliminar esta sesión?"),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("CANCELAR")),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("ELIMINAR", style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );
  }
}
