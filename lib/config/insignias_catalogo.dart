import 'package:flutter/material.dart';

/// Define la estructura estática de una insignia: qué es, no el progreso del usuario.
class InsigniaDefinition {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final IconData icono;
  final int metaTotal;

  InsigniaDefinition({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.icono,
    this.metaTotal = 1, // Por defecto, las insignias solo necesitan 1 acción para completarse
  });
}

/// Catálogo central de todas las insignias disponibles en la aplicación.
final List<InsigniaDefinition> catalogoDeInsignias = [
  InsigniaDefinition(id: 'dg_ins_primera_comida', nombre: 'Primer Paso', categoria: 'DietaGeneral', descripcion: 'Registra tu primera comida.', icono: Icons.flag),
  InsigniaDefinition(id: 'dg_ins_primer_desayuno', nombre: 'Madrugador', categoria: 'DietaGeneral', descripcion: 'Registra tu primer desayuno.', icono: Icons.free_breakfast),
  InsigniaDefinition(id: 'dg_ins_primer_almuerzo', nombre: 'Buen Provecho', categoria: 'DietaGeneral', descripcion: 'Registra tu primer almuerzo.', icono: Icons.restaurant),
  InsigniaDefinition(id: 'dg_ins_primera_cena', nombre: 'Bajo las Estrellas', categoria: 'DietaGeneral', descripcion: 'Registra tu primera cena.', icono: Icons.nightlight_round),
  InsigniaDefinition(id: 'dg_ins_primer_snack', nombre: 'Tentempié', categoria: 'DietaGeneral', descripcion: 'Registra tu primer snack.', icono: Icons.fastfood),
  InsigniaDefinition(id: 'dg_ins_10_comidas', nombre: 'Aprendiz Culinario', categoria: 'DietaGeneral', descripcion: 'Registra 10 comidas en total.', icono: Icons.format_list_numbered, metaTotal: 10),
  InsigniaDefinition(id: 'dg_ins_50_comidas', nombre: 'Habituado', categoria: 'DietaGeneral', descripcion: 'Registra 50 comidas en total.', icono: Icons.fact_check, metaTotal: 50),
  InsigniaDefinition(id: 'dg_ins_100_comidas', nombre: 'Veterano del Sabor', categoria: 'DietaGeneral', descripcion: 'Registra 100 comidas en total.', icono: Icons.military_tech, metaTotal: 100),
  InsigniaDefinition(id: 'ps_ins_primer_plan', nombre: 'Arquitecto de Dietas', categoria: 'PlanSemanal', descripcion: 'Crea tu primer plan de comidas semanal.', icono: Icons.edit_calendar),
  InsigniaDefinition(id: 'ps_ins_plan_completo', nombre: 'Semana Organizada', categoria: 'PlanSemanal', descripcion: 'Crea un plan con al menos 1 comida para cada día de la semana.', icono: Icons.date_range),
  InsigniaDefinition(id: 're_ins_primera_receta', nombre: 'Tu Primera Creación', categoria: 'Recetas', descripcion: 'Crea y guarda tu primera receta personalizada.', icono: Icons.lightbulb_outline),
  InsigniaDefinition(id: 're_ins_primera_receta_guardada', nombre: 'Inspiración Externa', categoria: 'Recetas', descripcion: 'Guarda tu primera receta de la comunidad.', icono: Icons.get_app),
  InsigniaDefinition(id: 'ac_ins_primer_entrenamiento', nombre: 'A Sudar', categoria: 'Actividad', descripcion: 'Registra tu primer entrenamiento.', icono: Icons.fitness_center),
  InsigniaDefinition(id: 'ac_ins_primera_hora', nombre: 'Una Hora de Poder', categoria: 'Actividad', descripcion: 'Completa un entrenamiento de al menos 60 minutos.', icono: Icons.timer),
  InsigniaDefinition(id: 'ag_ins_primer_vaso', nombre: '¡Salud!', categoria: 'Agua', descripcion: 'Registra tu primer vaso de agua.', icono: Icons.local_drink),
  InsigniaDefinition(id: 'ag_ins_meta_diaria', nombre: 'Meta de Hidratación', categoria: 'Agua', descripcion: 'Alcanza tu meta diaria de agua por primera vez.', icono: Icons.flare),
  InsigniaDefinition(id: 'me_ins_primer_peso', nombre: 'Punto de Partida', categoria: 'Medidas', descripcion: 'Registra tu peso por primera vez.', icono: Icons.monitor_weight_outlined),
  InsigniaDefinition(id: 'me_ins_primeras_medidas', nombre: 'Midiendo el Progreso', categoria: 'Medidas', descripcion: 'Registra tu conjunto completo de medidas corporales.', icono: Icons.straighten),
];
