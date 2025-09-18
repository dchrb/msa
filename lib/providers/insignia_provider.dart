// lib/providers/insignia_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:msa/models/insignia.dart';
import 'package:msa/models/tipo_plato.dart';
import 'package:msa/models/tipo_ejercicio.dart';
import 'package:msa/models/sesion_entrenamiento.dart';
import 'package:msa/providers/water_provider.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:msa/providers/meta1_provider.dart';
import 'package:msa/models/agua.dart';
import 'package:msa/providers/medida_provider.dart'; 
import 'package:msa/models/medida.dart'; 
import 'package:msa/providers/meta_provider.dart'; // Importado para la racha

class InsigniaProvider with ChangeNotifier {
  // --- LISTA DEFINITIVA DE INSIGNIAS ---
  final List<Insignia> _insignias = [
    // Perfil y Uso
    Insignia(id: 'perfil_1', nombre: '¡Todo Listo!', descripcion: 'Has creado tu perfil personal.', icono: Icons.account_circle),
    Insignia(id: 'explorador_1', nombre: 'Explorador', descripcion: 'Has usado todas las funciones de registro.', icono: Icons.explore),
    Insignia(id: 'personalizador_1', nombre: 'Con Estilo', descripcion: 'Has personalizado el color de la app.', icono: Icons.color_lens),
    Insignia(id: 'curioso_1', nombre: 'Curioso', descripcion: 'Has visitado la sección "Acerca de".', icono: Icons.help_outline),
    
    // Hidratación
    Insignia(id: 'agua_1', nombre: 'Primer Vaso', descripcion: '¡Has registrado tu primer vaso de agua!', icono: Icons.local_drink),
    Insignia(id: 'agua_meta_1', nombre: 'Meta Diaria (Agua)', descripcion: '¡Completaste tu objetivo de hidratación de hoy!', icono: Icons.check_circle, esDiaria: true),
    Insignia(id: 'agua_vol_5L', nombre: 'Bronce', descripcion: '¡Alcanzaste 5 litros este mes!', icono: Icons.opacity),
    Insignia(id: 'agua_vol_15L', nombre: 'Plata', descripcion: '¡Alcanzaste 15 litros este mes!', icono: Icons.opacity),
    Insignia(id: 'agua_vol_30L', nombre: 'Oro', descripcion: '¡Alcanzaste 30 litros este mes!', icono: Icons.opacity),

    // Nutrición
    Insignia(id: 'comida_1', nombre: 'Primer Plato', descripcion: '¡Registraste tu primera comida!', icono: Icons.restaurant_menu),
    Insignia(id: 'comida_trio_1', nombre: 'Trío Perfecto', descripcion: 'Registraste desayuno, almuerzo y cena hoy.', icono: Icons.fastfood, esDiaria: true),
    Insignia(id: 'comida_calorias_1', nombre: 'En el Blanco', descripcion: 'Cumpliste tu meta de calorías de hoy.', icono: Icons.gps_fixed, esDiaria: true),
    
    // Actividad Física
    Insignia(id: 'entrenamiento_1', nombre: 'A Calentar', descripcion: '¡Completaste tu primer entrenamiento!', icono: Icons.directions_run),
    Insignia(id: 'entrenamiento_fuerza_1', nombre: 'Pura Fuerza', descripcion: 'Registraste tu primer ejercicio de fuerza.', icono: Icons.fitness_center),
    Insignia(id: 'entrenamiento_cardio_1', nombre: 'Maratonista', descripcion: 'Registraste tu primer ejercicio de cardio.', icono: Icons.favorite),
    Insignia(id: 'entrenamiento_multi_1', nombre: 'Multidisciplinario', descripcion: 'Hiciste fuerza, cardio y flexibilidad en una sesión.', icono: Icons.star),
    Insignia(id: 'entrenamiento_finde_1', nombre: 'Guerrero de Fin de Semana', descripcion: 'Completaste un entrenamiento en sábado o domingo.', icono: Icons.wb_sunny),

    // Medidas y Peso (¡Nuevas insignias!)
    Insignia(id: 'medidas_1', nombre: 'Mi Primer Registro', descripcion: 'Has guardado tus primeras medidas corporales.', icono: Icons.scale),
    Insignia(id: 'peso_hito_1', nombre: 'Primer Kilo Abajo', descripcion: 'Has perdido tu primer kilogramo.', icono: Icons.trending_down),
    Insignia(id: 'peso_hito_5', nombre: 'Cinco Kilos Menos', descripcion: 'Has perdido 5 kilogramos.', icono: Icons.trending_down),
    Insignia(id: 'peso_hito_10', nombre: 'Diez Kilos Menos', descripcion: 'Has perdido 10 kilogramos.', icono: Icons.trending_down),

    // Consistencia
    Insignia(id: 'habito_trio_1', nombre: 'El Trío Definitivo', descripcion: 'Registraste agua, comida y entrenamiento hoy.', icono: Icons.all_inclusive, esDiaria: true),
    Insignia(id: 'habito_madrugador_1', nombre: 'Madrugador', descripcion: 'Registraste una actividad antes de las 8 AM.', icono: Icons.light_mode, esDiaria: true),
  ];

  Map<String, Insignia> _insigniasObtenidas = {};
  
  InsigniaProvider() {
  }

  List<Insignia> get insignias => _insignias;

  Future<void> cargarInsignias() async {
    final prefs = await SharedPreferences.getInstance();
    for (var insignia in _insignias) {
      final key = 'insignia_${insignia.id}';
      if (prefs.getBool(key) == true) {
        _insigniasObtenidas[insignia.id] = insignia..obtenida = true;
      }
    }
    notifyListeners();
  }

  Future<void> otorgarInsignia(String id, BuildContext context) async {
    if (_insigniasObtenidas.containsKey(id)) return;

    final insignia = _insignias.firstWhere((i) => i.id == id);
    insignia.obtenida = true;
    _insigniasObtenidas[id] = insignia;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('insignia_$id', true);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Nueva insignia obtenida: ${insignia.nombre}!'), backgroundColor: Colors.amber[600]),
      );
    }
    notifyListeners();
  }
  
  void verificarInsigniaDePerfil(BuildContext context) {
    otorgarInsignia('perfil_1', context);
  }

  void verificarInsigniaExplorador(
    BuildContext context,
    WaterProvider waterProvider,
    FoodProvider foodProvider,
    MedidaProvider medidaProvider,
    EntrenamientoProvider entrenamientoProvider,
  ) {
    // La insignia se otorga si hay al menos un registro en cada categoría
    final haRegistradoAgua = waterProvider.registros.isNotEmpty;
    final haRegistradoComida = foodProvider.platos.isNotEmpty;
    final haRegistradoMedidas = medidaProvider.registros.isNotEmpty;
    final haRegistradoEntrenamiento = entrenamientoProvider.sesiones.isNotEmpty;
    
    if (haRegistradoAgua && haRegistradoComida && haRegistradoMedidas && haRegistradoEntrenamiento) {
      otorgarInsignia('explorador_1', context);
    }
  }


  void verificarInsigniasDeMedidas(BuildContext context, MedidaProvider medidaProvider) {
    if (medidaProvider.registros.isNotEmpty) {
      otorgarInsignia('medidas_1', context);
    }

    // Lógica para hitos de pérdida de peso
    if (medidaProvider.registros.length > 1) {
      final primerPeso = medidaProvider.registros.last.peso;
      final pesoActual = medidaProvider.registros.first.peso;
      final perdida = primerPeso - pesoActual;

      if (perdida >= 1) otorgarInsignia('peso_hito_1', context);
      if (perdida >= 5) otorgarInsignia('peso_hito_5', context);
      if (perdida >= 10) otorgarInsignia('peso_hito_10', context);
    }
  }

  void verificarInsigniasDeAgua(BuildContext context, WaterProvider waterProvider, DateTime fecha) {
    if (waterProvider.getRegistrosPorFecha(fecha).isNotEmpty) {
      otorgarInsignia('agua_1', context);
    }

    final totalIngestaMensual = waterProvider.registros
      .where((r) => r.timestamp.month == DateTime.now().month && r.timestamp.year == DateTime.now().year)
      .map((r) => r.amount)
      .fold(0.0, (sum, amount) => sum + amount);
    
    if (totalIngestaMensual >= 5000) otorgarInsignia('agua_vol_5L', context);
    if (totalIngestaMensual >= 15000) otorgarInsignia('agua_vol_15L', context);
    if (totalIngestaMensual >= 30000) otorgarInsignia('agua_vol_30L', context);

    if (waterProvider.getIngestaPorFecha(fecha) >= waterProvider.meta) {
      otorgarInsignia('agua_meta_1', context);
    }
  }

  void verificarInsigniasDeComida(BuildContext context, FoodProvider foodProvider, Meta1Provider meta1Provider) {
    if (foodProvider.platos.isNotEmpty) {
      otorgarInsignia('comida_1', context);
    }
    final platosHoy = foodProvider.getPlatosPorFecha(DateTime.now());
    final tiposDePlatoHoy = platosHoy.map((p) => p.tipo).toSet();
    if (tiposDePlatoHoy.containsAll([TipoPlato.desayuno, TipoPlato.almuerzo, TipoPlato.cena])) {
      otorgarInsignia('comida_trio_1', context);
    }
    final caloriasHoy = foodProvider.getCaloriasPorFecha(DateTime.now());
    if (caloriasHoy > 0 && caloriasHoy <= meta1Provider.metaCalorias) {
      otorgarInsignia('comida_calorias_1', context);
    }
  }

  void verificarInsigniasDeEntrenamiento(BuildContext context, EntrenamientoProvider entrenamientoProvider, SesionEntrenamiento sesion) {
    if (entrenamientoProvider.sesiones.isNotEmpty) {
      otorgarInsignia('entrenamiento_1', context);
    }
    final tiposEnSesion = sesion.detalles.map((d) {
      final ejercicio = entrenamientoProvider.getEjercicioPorId(d.ejercicioId);
      return ejercicio?.tipo;
    }).toSet();

    if (tiposEnSesion.contains(TipoEjercicio.fuerza)) otorgarInsignia('entrenamiento_fuerza_1', context);
    if (tiposEnSesion.contains(TipoEjercicio.cardio)) otorgarInsignia('entrenamiento_cardio_1', context);
    if (tiposEnSesion.containsAll([TipoEjercicio.fuerza, TipoEjercicio.cardio, TipoEjercicio.flexibilidad])) {
      otorgarInsignia('entrenamiento_multi_1', context);
    }
    final diaDeLaSemana = sesion.fecha.weekday;
    if (diaDeLaSemana == DateTime.saturday || diaDeLaSemana == DateTime.sunday) {
      otorgarInsignia('entrenamiento_finde_1', context);
    }
  }

  void verificarInsigniaMadrugador(BuildContext context) {
    final ahora = DateTime.now();
    if (ahora.hour < 8) {
      otorgarInsignia('habito_madrugador_1', context);
    }
  }
  
  void verificarInsigniaCurioso(BuildContext context) {
    otorgarInsignia('curioso_1', context);
  }
  
  void verificarHabitoTrio(
      BuildContext context,
      WaterProvider waterProvider,
      FoodProvider foodProvider,
      EntrenamientoProvider entrenamientoProvider,
  ) {
    final hoy = DateTime.now();
    final haRegistradoAgua = waterProvider.getIngestaPorFecha(hoy) > 0;
    final haRegistradoComida = foodProvider.getPlatosPorFecha(hoy).isNotEmpty;
    final haRegistradoEntrenamiento = entrenamientoProvider.sesiones
        .any((s) => s.fecha.year == hoy.year && s.fecha.month == hoy.month && s.fecha.day == hoy.day);
    
    if (haRegistradoAgua && haRegistradoComida && haRegistradoEntrenamiento) {
      otorgarInsignia('habito_trio_1', context);
    }
  }
}