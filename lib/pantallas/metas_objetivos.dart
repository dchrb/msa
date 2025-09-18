// lib/pantallas/metas_objetivos.dart

import 'package:flutter/material.dart';
import 'package:msa/providers/meta_provider.dart';
import 'package:provider/provider.dart';

class MetasObjetivos extends StatelessWidget {
  const MetasObjetivos({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un Consumer para que la pantalla se actualice si la racha cambia.
    return Consumer<MetaProvider>(
      builder: (context, metaProvider, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // <-- LÍNEA AÑADIDA
            title: const Text('Metas y Objetivos'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: metaProvider.metas.length,
            itemBuilder: (context, index) {
              final meta = metaProvider.metas[index];
              // Calculamos el progreso para la barra (un valor entre 0.0 y 1.0)
              final progreso = (meta.rachaActual / meta.objetivoRacha).clamp(0.0, 1.0);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila con el título y el ícono de completado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Usamos Flexible para que el texto no se desborde si es largo
                          Flexible(
                            child: Text(
                              meta.titulo,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Mostramos un ícono de trofeo si la meta está completada
                          if (meta.completada)
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 30,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meta.descripcion,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      // Barra de progreso
                      LinearProgressIndicator(
                        value: progreso,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        borderRadius: BorderRadius.circular(5), // Bordes redondeados
                      ),
                      const SizedBox(height: 8),
                      // Texto que muestra la racha actual
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${meta.rachaActual} / ${meta.objetivoRacha} días',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}