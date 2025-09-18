import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msa/models/ejercicio.dart';
import 'package:msa/models/sesion_entrenamiento.dart';
import 'package:msa/pantallas/pantalla_registro_sesion.dart';
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:provider/provider.dart';
import 'package:msa/models/detalle_ejercicio.dart';
import 'package:msa/models/serie.dart';

class PantallaDetalleSesion extends StatelessWidget {
  final SesionEntrenamiento sesion;

  const PantallaDetalleSesion({super.key, required this.sesion});

  @override
  Widget build(BuildContext context) {
    final entrenamientoProvider = context.read<EntrenamientoProvider>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(sesion.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PantallaRegistroSesion(sesionAEditar: sesion),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, dd MMMM yyyy', 'es_ES').format(sesion.fecha),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const Divider(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sesion.detalles.length,
              itemBuilder: (context, index) {
                final detalle = sesion.detalles[index];
                final Ejercicio? ejercicio = entrenamientoProvider.getEjercicioPorId(detalle.ejercicioId);

                if (ejercicio == null) {
                  return const Card(
                    child: ListTile(title: Text('Ejercicio no encontrado')),
                  );
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ejercicio.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Serie', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Repeticiones', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Peso (kg)', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            ...detalle.series.asMap().entries.map((entry) {
                              int serieIndex = entry.key;
                              Serie serie = entry.value;
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${serieIndex + 1}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${serie.repeticiones}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${serie.pesoKg}'),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}