// lib/pantallas/pantalla_comidas_tabs.dart

import 'package:flutter/material.dart';
import 'package:msa/pantallas/pantalla_comidas_hoy.dart';
import 'package:msa/pantallas/pantalla_historial_comidas.dart';

class PantallaComidasTabs extends StatelessWidget {
  const PantallaComidasTabs({super.key});

  @override
  Widget build(BuildContext context) {
    // CAMBIO: Se eliminó el Scaffold y el AppBar para quitar la barra duplicada.
    // Ahora, este widget solo organiza las pestañas internas.
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            // Se ajustan los colores para que se vean bien sin AppBar
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.today), text: 'Hoy'),
              Tab(icon: Icon(Icons.history), text: 'Historial'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                PantallaComidasHoy(),
                PantallaHistorialComidas(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}