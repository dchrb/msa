// lib/pantallas/recompensas.dart

import 'package:flutter/material.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:provider/provider.dart';
import 'package:msa/models/insignia.dart'; // Asegúrate de importar el modelo Insignia

class Recompensas extends StatelessWidget {
  const Recompensas({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InsigniaProvider>(
      builder: (context, insigniaProvider, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // <-- LÍNEA AÑADIDA
            title: const Text('Mis Recompensas'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: insigniaProvider.insignias.length,
              itemBuilder: (context, index) {
                final insignia = insigniaProvider.insignias[index];
                // CORRECCIÓN: Usamos Colors.grey.shade400 para evitar valores nulos
                final color = insignia.obtenida ? Colors.amber : Colors.grey.shade400;
              final textColor = insignia.obtenida ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

                return InkWell(
                  onTap: () => _mostrarDetallesInsignia(context, insignia, color),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            insignia.icono,
                            size: 50,
                            color: color,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            insignia.nombre,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _mostrarDetallesInsignia(BuildContext context, Insignia insignia, Color color) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Icon(insignia.icono, size: 80, color: color),
                    const SizedBox(height: 10),
                    Text(
                      insignia.nombre,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      insignia.descripcion,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      insignia.obtenida ? '¡Insignia obtenida!' : 'Aún no has obtenido esta insignia.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: insignia.obtenida ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}