import 'package:flutter/material.dart';
import 'package:msa/pantallas/pantalla_biblioteca_ejercicios.dart';
import 'package:msa/pantallas/pantalla_historial_entrenamientos.dart';

class PantallaActividadFisicaTabs extends StatelessWidget {
  final int initialIndex;
  const PantallaActividadFisicaTabs({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Actividad Física'),
          bottom: const TabBar(
            tabs: [
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