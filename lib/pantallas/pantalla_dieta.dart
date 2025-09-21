import 'package:flutter/material.dart';
import 'package:msa/pantallas/menu_del_dia.dart';
import 'package:msa/pantallas/menu_semanal.dart';
import 'package:msa/pantallas/ideas_de_comida.dart';
import 'package:msa/pantallas/pantalla_mis_recetas.dart'; // Importado

class PantallaDieta extends StatelessWidget {
  const PantallaDieta({super.key});

  @override
  Widget build(BuildContext context) {
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
