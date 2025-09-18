// lib/models/insignia.dart

import 'package:flutter/material.dart';

class Insignia {
  final String id;
  final String nombre;
  final String descripcion;
  final IconData icono;
  bool obtenida;
  final bool esDiaria;

  Insignia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    this.obtenida = false,
    this.esDiaria = false,
  });
}