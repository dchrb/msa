import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:msa/models/models.dart';
import 'package:msa/config/rachas_catalogo.dart';
import 'package:msa/utils/date_utils.dart' as msa_date_utils;

// --- Clases Compuestas (para la UI) ---

class RachaCompuesta {
  final Racha rachaUsuario;
  final RachaDefinition definicion;

  RachaCompuesta({required this.rachaUsuario, required this.definicion});

  String get id => definicion.id;
  String get nombre => definicion.nombre;
  String get descripcion => definicion.descripcion;
  IconData get icono => definicion.icono;
  int get rachaActual => rachaUsuario.rachaActual;
  int get rachaMasAlta => rachaUsuario.rachaMasAlta;
}

// --- Provider de Rachas (Refactorizado) ---

class RachaProvider with ChangeNotifier {
  late Box<Racha> _box;
  final List<RachaCompuesta> _rachas = [];
  bool _isLoading = true;

  List<RachaCompuesta> get rachas => _rachas;
  bool get isLoading => _isLoading;

  RachaProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<Racha>('rachas');
    _cargarRachas();
    _isLoading = false;
    notifyListeners();
  }

  void _cargarRachas() {
    _rachas.clear();
    
    for (var def in catalogoDeRachas) {
      Racha rachaUsuario = _box.get(def.id) ?? Racha(id: def.id, nombre: def.nombre, descripcion: def.descripcion, icono: def.icono.toString());
      
      if (!_box.containsKey(def.id)) {
        _box.put(def.id, rachaUsuario);
      }

      _rachas.add(RachaCompuesta(rachaUsuario: rachaUsuario, definicion: def));
    }
    notifyListeners();
  }

  void actualizarRacha(String id, bool condicionCumplida) {
    final rachaComp = _rachas.firstWhere((r) => r.id == id);
    final rachaDef = rachaComp.definicion;
    final rachaUsuario = rachaComp.rachaUsuario;

    final hoy = DateTime.now();
    final ultimaVez = rachaUsuario.ultimaVezActualizada;

    if (!condicionCumplida) {
      if (ultimaVez != null && !msa_date_utils.DateUtils.isSameDay(ultimaVez, hoy)) {
         rachaUsuario.rachaActual = 0;
         rachaUsuario.save();
         notifyListeners();
      }
      return;
    }

    if (ultimaVez != null && msa_date_utils.DateUtils.isSameDay(ultimaVez, hoy)) {
      return;
    }

    bool esConsecutivo = false;
    if (ultimaVez != null) {
      if (rachaDef.tipo == TipoRacha.diaria && msa_date_utils.DateUtils.isYesterday(ultimaVez, hoy)) {
        esConsecutivo = true;
      } else if (rachaDef.tipo == TipoRacha.semanal && msa_date_utils.DateUtils.isLastWeek(ultimaVez, hoy)){
        esConsecutivo = true;
      }
    }

    if (esConsecutivo) {
      rachaUsuario.rachaActual++;
    } else {
      rachaUsuario.rachaActual = 1;
    }

    if (rachaUsuario.rachaActual > rachaUsuario.rachaMasAlta) {
      rachaUsuario.rachaMasAlta = rachaUsuario.rachaActual;
    }

    rachaUsuario.ultimaVezActualizada = hoy;
    rachaUsuario.save();
    notifyListeners();
  }

  void verificarRachasDiarias(bool condicion, String id) {
    actualizarRacha(id, condicion);
  }
}
