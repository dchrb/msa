// lib/pantallas/pantalla_actividad_fisica.dart

import 'package:flutter/material.dart';
import 'package:msa/pantallas/pantalla_biblioteca_ejercicios.dart';
import 'package:msa/pantallas/pantalla_historial_entrenamientos.dart';

class PantallaActividadFisica extends StatelessWidget {
  const PantallaActividadFisica({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad Física'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActividadCard(context, 'Historial de Entrenamientos', Icons.fitness_center, const PantallaHistorialEntrenamientos()),
          _buildActividadCard(context, 'Biblioteca de Ejercicios', Icons.menu_book, const PantallaBibliotecaEjercicios()),
        ],
      ),
    );
  }

  Widget _buildActividadCard(BuildContext context, String title, IconData icon, Widget page) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}