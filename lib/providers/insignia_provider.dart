import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:msa/models/models.dart';
import 'package:msa/config/insignias_catalogo.dart';

// --- Clases Compuestas (para la UI) ---

/// Une el dato guardado (progreso) con su definición estática (info).
class InsigniaCompuesta {
  final Insignia insigniaUsuario; // El dato de Hive
  final InsigniaDefinition definicion; // La info del catálogo

  InsigniaCompuesta({required this.insigniaUsuario, required this.definicion});

  // Getters para fácil acceso desde la UI
  String get id => definicion.id;
  String get nombre => definicion.nombre;
  String get descripcion => definicion.descripcion;
  IconData get icono => definicion.icono;
  int get metaTotal => definicion.metaTotal;
  int get progresoActual => insigniaUsuario.nivelAlcanzado; // Asumimos que nivelAlcanzado es el progreso

  bool get obtenida => progresoActual > 0;
  bool get completadaTotalmente => progresoActual >= metaTotal;
  double get progresoNormalizado => (progresoActual / metaTotal).clamp(0.0, 1.0);
  String get textoProgreso => '$progresoActual / $metaTotal';
}

// --- Provider de Insignias (Refactorizado) ---

class InsigniaProvider with ChangeNotifier {
  late Box<Insignia> _box;
  final List<InsigniaCompuesta> _insignias = [];
  bool _isLoading = true;

  List<InsigniaCompuesta> get insignias => _insignias;
  List<InsigniaCompuesta> get insigniasDesbloqueadas => _insignias.where((i) => i.obtenida).toList();
  List<InsigniaCompuesta> get insigniasBloqueadas => _insignias.where((i) => !i.obtenida).toList();
  bool get isLoading => _isLoading;

  InsigniaProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<Insignia>('insignias');
    _cargarInsignias();
    _isLoading = false;
    notifyListeners();
  }

  void _cargarInsignias() {
    _insignias.clear();
    
    for (var def in catalogoDeInsignias) {
      // Busca la insignia del usuario en la caja. Si no existe, crea una nueva por defecto.
      Insignia insigniaUsuario = _box.get(def.id) ?? Insignia(id: def.id, nivelAlcanzado: 0);
      
      // Si el objeto no estaba en la caja, lo añadimos para futuros accesos.
      if (!_box.containsKey(def.id)) {
        _box.put(def.id, insigniaUsuario);
      }

      _insignias.add(InsigniaCompuesta(insigniaUsuario: insigniaUsuario, definicion: def));
    }
    notifyListeners();
  }

  /// Otorga progreso a una insignia. Si la cantidad es 0, la marca como obtenida (para metas de 1).
  void otorgarInsignia(String id, {int cantidad = 1, bool esReemplazo = false}) {
    final insigniaCompuesta = _insignias.firstWhere((i) => i.id == id, orElse: () => throw Exception('Insignia no encontrada en el catálogo'));
    final insigniaUsuario = insigniaCompuesta.insigniaUsuario;

    if (insigniaCompuesta.completadaTotalmente && !esReemplazo) return; // Ya está completada

    if (esReemplazo) {
      insigniaUsuario.nivelAlcanzado = cantidad;
    } else {
       if (insigniaCompuesta.metaTotal == 1 && insigniaUsuario.nivelAlcanzado == 0) {
         insigniaUsuario.nivelAlcanzado = 1; // Para insignias de un solo paso
       } else {
         insigniaUsuario.nivelAlcanzado += cantidad;
       }
    }

    // Guardar el progreso en Hive
    insigniaUsuario.save();

    notifyListeners();
  }
  
  // LÓGICA DE VERIFICACIÓN (SIMPLIFICADA)
  // Estos métodos ahora solo delegan a `otorgarInsignia` y no usan BuildContext.

  void verificarInsigniasPorRegistroDeComida(Plato plato) {
    otorgarInsignia('dg_ins_primera_comida');
    otorgarInsignia('dg_ins_10_comidas', esReemplazo: false); // Esto debería ser un contador
  }

  void verificarInsigniasPorPlanSemanal(int diasCompletos) {
     otorgarInsignia('ps_ins_primer_plan');
     if (diasCompletos >= 7) {
       otorgarInsignia('ps_ins_plan_completo');
     }
  }

  void verificarInsigniasPorCreacionReceta() {
    otorgarInsignia('re_ins_primera_receta');
  }

  void verificarInsigniasPorActividad(SesionEntrenamiento sesion) {
    otorgarInsignia('ac_ins_primer_entrenamiento');
    final duracionTotal = sesion.detalles.fold<double>(0, (sum, d) => sum + (d.duracionMinutos ?? 0));
    if (duracionTotal >= 60) {
      otorgarInsignia('ac_ins_primera_hora');
    }
  }

  void verificarInsigniasPorConsumoAgua(int ingestaHoy, int meta) {
    if (ingestaHoy > 0) {
      otorgarInsignia('ag_ins_primer_vaso');
    }
    if (meta > 0 && ingestaHoy >= meta) {
      otorgarInsignia('ag_ins_meta_diaria');
    }
  }

  void verificarInsigniasPorMedidas(int numeroDeMedidas) {
    if (numeroDeMedidas > 0) {
      otorgarInsignia('me_ins_primer_peso'); // Asume que el peso siempre se incluye
    }
    if (numeroDeMedidas >= 5) {
      otorgarInsignia('me_ins_primeras_medidas');
    }
  }
}
