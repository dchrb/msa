import 'package:flutter/material.dart';
import 'package:msa/pantallas/menu_del_dia.dart';
import 'package:msa/pantallas/menu_semanal.dart';
import 'package:msa/pantallas/ideas_de_comida.dart';
import 'package:msa/pantallas/pantalla_mis_recetas.dart'; // Importado

class PantallaDietaTabs extends StatelessWidget {
  const PantallaDietaTabs({super.key});

  @override
  Widget build(BuildContext context) {
    // Este widget ahora solo contiene la VISTA de las pestañas (el contenido).
    // La barra con los botones de las pestañas (la TabBar) se controla desde la pantalla de inicio.
    return const TabBarView(
      children: [
        MenuDelDia(),
        MenuSemanal(),
        IdeasDeComida(),
        PantallaMisRecetas(), // Añadido
      ],
    );
  }
}
