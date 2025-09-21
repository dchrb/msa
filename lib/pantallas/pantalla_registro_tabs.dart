// lib/pantallas/pantalla_registro_tabs.dart

import 'package:flutter/material.dart';
import 'package:msa/pantallas/ingesta_agua.dart';
import 'package:msa/pantallas/pantalla_comidas_tabs.dart';
// --- CAMBIO 1: Importamos nuestro nuevo widget de pestañas ---
import 'package:msa/pantallas/pantalla_medidas_tabs.dart';

class PantallaRegistroTabs extends StatelessWidget {
  final int initialIndex;
  const PantallaRegistroTabs({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DefaultTabController(
      initialIndex: initialIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registrar Actividades'),
          bottom: TabBar(
            labelColor: colors.onPrimary,
            unselectedLabelColor: colors.onPrimary.withAlpha(178),
            indicatorColor: colors.onPrimary,
            tabs: const [
              Tab(icon: Icon(Icons.local_drink), text: 'Agua'),
              Tab(icon: Icon(Icons.fastfood), text: 'Comidas'),
              Tab(icon: Icon(Icons.scale), text: 'Medidas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            IngestaAgua(),
            PantallaComidasTabs(),
            // --- CAMBIO 2: Usamos nuestro nuevo contenedor de pestañas ---
            PantallaMedidasTabs(),
          ],
        ),
      ),
    );
  }
}