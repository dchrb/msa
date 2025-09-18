// lib/pantallas/pantalla_medidas_tabs.dart

import 'package:flutter/material.dart';
import 'package:msa/pantallas/pantalla_historial_medidas.dart';
import 'package:msa/pantallas/pantalla_registro_medidas.dart';

class PantallaMedidasTabs extends StatelessWidget {
  const PantallaMedidasTabs({super.key});

  @override
  Widget build(BuildContext context) {
    // CAMBIO: Se eliminó el Scaffold y el AppBar para quitar la barra duplicada.
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.add_chart), text: 'Registrar'),
              Tab(icon: Icon(Icons.history), text: 'Historial'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                PantallaRegistroMedidas(),
                PantallaHistorialMedidas(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}