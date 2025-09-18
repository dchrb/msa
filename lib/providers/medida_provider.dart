// lib/providers/medida_provider.dart

import 'package:flutter/foundation.dart'; 
import 'package:msa/models/medida.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class MedidaProvider with ChangeNotifier {
  Map<String, dynamic> _perfil = {};
  late Box<Medida> _medidasBox;
  bool _isLoading = true;
  double? _metaPeso; // Nuevo campo para la meta de peso

  Map<String, dynamic> get perfil => _perfil;
  List<Medida> get registros => _medidasBox.values.toList()..sort((a, b) => b.fecha.compareTo(a.fecha));
  bool get isLoading => _isLoading;
  double? get metaPeso => _metaPeso;

  MedidaProvider() {
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    _perfil = {
      'nombre': prefs.getString('perfil_nombre'),
      'edad': prefs.getInt('perfil_edad'),
      'sexo': prefs.getString('perfil_sexo'),
      'altura': prefs.getDouble('perfil_altura'),
    };
    
    _medidasBox = Hive.box<Medida>('medidasBox');
    _metaPeso = prefs.getDouble('meta_peso'); // Cargar la meta de peso
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> guardarPerfil(Map<String, dynamic> nuevoPerfil) async {
    _perfil = nuevoPerfil;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfil_nombre', nuevoPerfil['nombre'] as String);
    await prefs.setInt('perfil_edad', nuevoPerfil['edad'] as int);
    await prefs.setString('perfil_sexo', nuevoPerfil['sexo'] as String);
    await prefs.setDouble('perfil_altura', nuevoPerfil['altura'] as double);
    notifyListeners();
  }

  void agregarMedida({
    required double peso,
    required double altura,
    double? pecho,
    double? brazo,
    double? cintura,
    double? caderas,
    double? muslo,
  }) {
    final nuevaMedida = Medida(
      id: const Uuid().v4(),
      fecha: DateTime.now(),
      peso: peso,
      altura: altura,
      pecho: pecho,
      brazo: brazo,
      cintura: cintura,
      caderas: caderas,
      muslo: muslo,
    );
    _medidasBox.put(nuevaMedida.id, nuevaMedida);

    // Lógica para verificar si se cumple el objetivo de peso
    if (_metaPeso != null && peso <= _metaPeso!) {
      // La lógica para otorgar la insignia 'peso_meta_1'
      // se hará en la pantalla, ya que necesita el contexto.
    }
    
    notifyListeners();
  }
  
  void editarMedida(String id, {
    required double peso,
    required double altura,
    double? pecho,
    double? brazo,
    double? cintura,
    double? caderas,
    double? muslo,
  }) {
    final medidaAEditar = _medidasBox.get(id);
    if (medidaAEditar != null) {
      medidaAEditar.peso = peso;
      medidaAEditar.altura = altura;
      medidaAEditar.pecho = pecho;
      medidaAEditar.brazo = brazo;
      medidaAEditar.cintura = cintura;
      medidaAEditar.caderas = caderas;
      medidaAEditar.muslo = muslo;
      medidaAEditar.save();
    }
    notifyListeners();
  }

  void eliminarMedida(String id) {
    _medidasBox.delete(id);
    notifyListeners();
  }
  
  // Nuevo método para establecer la meta de peso
  Future<void> setMetaPeso(double? peso) async {
    final prefs = await SharedPreferences.getInstance();
    if (peso != null) {
      await prefs.setDouble('meta_peso', peso);
    } else {
      await prefs.remove('meta_peso');
    }
    _metaPeso = peso;
    notifyListeners();
  }
}