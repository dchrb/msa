// lib/pantallas/pantalla_actividad_fisica_tabs.dart

import 'package:flutter/material.dart';
import 'package:msa/pantallas/pantalla_biblioteca_ejercicios.dart';
import 'package:msa/pantallas/pantalla_historial_entrenamientos.dart';

class PantallaActividadFisicaTabs extends StatelessWidget {
  final int initialIndex;
  const PantallaActividadFisicaTabs({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DefaultTabController(
      initialIndex: initialIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // CAMBIO: Se quitó "automaticallyImplyLeading" para que la flecha principal SÍ aparezca.
          title: const Text('Actividad Física'),
          bottom: TabBar(
            labelColor: colors.onPrimary,
            unselectedLabelColor: colors.onPrimary.withOpacity(0.7),
            indicatorColor: colors.onPrimary,
            tabs: const [
              Tab(icon: Icon(Icons.history), text: 'Historial'),
              Tab(icon: Icon(Icons.menu_book), text: 'Biblioteca'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PantallaHistorialEntrenamientos(),
            PantallaBibliotecaEjercicios(),
          ],
        ),
      ),
    );
  }
}