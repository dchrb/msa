import 'package:flutter/material.dart'; // Por el IconData

// Define la periodicidad de una racha.
enum TipoRacha { diaria, semanal }

/// Define la estructura estática de una racha: qué es, no el progreso del usuario.
class RachaDefinition {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final IconData icono;
  final TipoRacha tipo;

  RachaDefinition({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.icono,
    required this.tipo,
  });
}

/// Catálogo central de todas las rachas disponibles en la aplicación.
final List<RachaDefinition> catalogoDeRachas = [
  RachaDefinition(id: 'dg_racha_registro_comida', nombre: 'Registro Diario', categoria: 'DietaGeneral', descripcion: 'Días seguidos registrando al menos una comida.', icono: Icons.edit_note, tipo: TipoRacha.diaria),
  RachaDefinition(id: 'dg_racha_desayuno', nombre: 'Amanecer Constante', categoria: 'DietaGeneral', descripcion: 'Días seguidos registrando tu desayuno.', icono: Icons.free_breakfast_outlined, tipo: TipoRacha.diaria),
  RachaDefinition(id: 'dg_racha_calorias', nombre: 'En el Blanco Calórico', categoria: 'DietaGeneral', descripcion: 'Días seguidos cumpliendo tu objetivo de calorías.', icono: Icons.adjust, tipo: TipoRacha.diaria),
  RachaDefinition(id: 'dg_racha_macros', nombre: 'Maestro de Macros', categoria: 'DietaGeneral', descripcion: 'Días seguidos cumpliendo tus 3 objetivos de macros.', icono: Icons.pie_chart_outline, tipo: TipoRacha.diaria),
  RachaDefinition(id: 'dg_racha_sin_ultraprocesados', nombre: 'Comida Real', categoria: 'DietaGeneral', descripcion: 'Días seguidos sin registrar alimentos ultra-procesados.', icono: Icons.no_food_outlined, tipo: TipoRacha.diaria),
  RachaDefinition(id: 'dg_racha_cinco_al_dia', nombre: 'Vitamina Pura', categoria: 'DietaGeneral', descripcion: 'Días seguidos comiendo 5+ porciones de fruta/verdura.', icono: Icons.local_florist_outlined, tipo: TipoRacha.diaria),
  
  RachaDefinition(id: 'ps_racha_plan_creado', nombre: 'Planificador Semanal', categoria: 'PlanSemanal', descripcion: 'Semanas seguidas creando un plan de comidas.', icono: Icons.calendar_today_outlined, tipo: TipoRacha.semanal),
  RachaDefinition(id: 'ps_racha_plan_seguido', nombre: 'Ejecutor Disciplinado', categoria: 'PlanSemanal', descripcion: 'Semanas seguidas cumpliendo >90% de tu plan.', icono: Icons.check_circle_outline, tipo: TipoRacha.semanal),

  RachaDefinition(id: 're_racha_receta_creada', nombre: 'Chef Creativo', categoria: 'Recetas', descripcion: 'Semanas seguidas creando una nueva receta.', icono: Icons.lightbulb_outline, tipo: TipoRacha.semanal),
  RachaDefinition(id: 're_racha_receta_guardada', nombre: 'Coleccionista Culinario', categoria: 'Recetas', descripcion: 'Semanas seguidas guardando una receta de la comunidad.', icono: Icons.bookmark_border, tipo: TipoRacha.semanal),

  RachaDefinition(id: 'ac_racha_entrenamiento', nombre: 'En Movimiento', categoria: 'Actividad', descripcion: 'Días seguidos completando un entrenamiento.', icono: Icons.fitness_center_outlined, tipo: TipoRacha.diaria),
  RachaDefinition(id: 'ac_racha_10k_pasos', nombre: 'Paso a Paso', categoria: 'Actividad', descripcion: 'Días seguidos alcanzando los 10,000 pasos.', icono: Icons.directions_walk_outlined, tipo: TipoRacha.diaria),

  RachaDefinition(id: 'ag_racha_meta_agua', nombre: 'Hidratación Diaria', categoria: 'Agua', descripcion: 'Días seguidos cumpliendo tu meta de agua.', icono: Icons.water_drop_outlined, tipo: TipoRacha.diaria),

  RachaDefinition(id: 'me_racha_pesaje', nombre: 'Consistencia en la Báscula', categoria: 'Medidas', descripcion: 'Semanas seguidas registrando tu peso.', icono: Icons.monitor_weight_outlined, tipo: TipoRacha.semanal),
];
