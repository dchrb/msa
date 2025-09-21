// lib/pantallas/pantalla_comidas_tabs.dart

import 'package:flutter/material.dart';
import 'package:msa/pantallas/pantalla_comidas_hoy.dart';
import 'package:msa/pantallas/pantalla_historial_comidas.dart';

class PantallaComidasTabs extends StatelessWidget {
  const PantallaComidasTabs({super.key});

  @override
  Widget build(BuildContext context) {
    // --- FIX: Se envuelve el contenido en un nuevo DefaultTabController ---
    // Esto es necesario porque este widget tiene su propio conjunto de pestañas
    // y necesita su propio controlador, independiente del de la pantalla padre.
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
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
