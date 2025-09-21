import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:msa/models/comida_planificada.dart';
import 'package:msa/models/plato.dart';

class DietaProvider with ChangeNotifier {
  final String _deepLApiKey = dotenv.env['DEEPL_API_KEY'] ?? '';
  late Box<ComidaPlanificada> _comidasBox;
  bool _isInitialized = false;

  List<dynamic> _ideasComidas = [];
  bool _isLoadingIdeas = false;
  String? _errorIdeas;

  List<dynamic> get ideasComidas => _ideasComidas;
  bool get isLoadingIdeas => _isLoadingIdeas;
  String? get errorIdeas => _errorIdeas;
  Box<ComidaPlanificada> get comidasBox => _comidasBox;
  bool get isInitialized => _isInitialized;

  DietaProvider() {
    _init();
  }

  Future<void> _init() async {
    _comidasBox = Hive.box<ComidaPlanificada>('comidasPlanificadasBox');
    _isInitialized = true;
    notifyListeners();
  }

  Map<int, List<ComidaPlanificada>> get menuSemanal {
    final Map<int, List<ComidaPlanificada>> menu = { for (var i = 1; i <= 7; i++) i: [] };
    for (var comida in _comidasBox.values) {
      if (menu.containsKey(comida.diaDeLaSemana)) {
        menu[comida.diaDeLaSemana]!.add(comida);
      }
    }
    return menu;
  }

  List<ComidaPlanificada> getMenuDelDia(int dia) => _comidasBox.values.where((c) => c.diaDeLaSemana == dia).toList();

  Future<void> agregarComidaPlanificada(int dia, String nombre, TipoPlato tipo) async {
    final nuevaComida = ComidaPlanificada(id: const Uuid().v4(), nombre: nombre, tipo: tipo, diaDeLaSemana: dia);
    await _comidasBox.put(nuevaComida.id, nuevaComida);
    notifyListeners();
  }

  Future<void> eliminarComidaPlanificada(String comidaId) async {
    await _comidasBox.delete(comidaId);
    notifyListeners();
  }

  Future<void> marcarComidaComoCompletada(String comidaId, bool isCompleted) async {
    final comida = _comidasBox.get(comidaId);
    if (comida != null) {
      comida.completado = isCompleted;
      await comida.save();
      notifyListeners();
    }
  }

  Future<void> replaceAllComidas(List<ComidaPlanificada> comidas) async {
    await _comidasBox.clear();
    for (var comida in comidas) {
      await _comidasBox.put(comida.id, comida);
    }
    notifyListeners();
  }

  Future<void> fetchIdeasComidas({required String categoria}) async {
    _setLoadingState(true);
    if (!_checkApiKey()) return; // Fallo rápido si no hay API Key

    try {
      final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/filter.php?c=$categoria");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _ideasComidas = (data['meals'] != null) ? await _translateRecipeTitles(data['meals'] as List<dynamic>) : [];
        _errorIdeas = null;
      } else {
        _setErrorState('No se pudieron obtener ideas en este momento (Error HTTP ${response.statusCode}).');
      }
    } catch (e) {
      _setErrorState('Error de conexión o traducción. Revisa tu acceso a internet e inténtalo de nuevo.');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> buscarRecetasPorNombre(String nombre) async {
    _setLoadingState(true);
    if (!_checkApiKey()) return;

    try {
      final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/search.php?s=${Uri.encodeComponent(nombre)}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _ideasComidas = (data['meals'] != null) ? await _translateRecipeTitles(data['meals'] as List<dynamic>) : [];
        _errorIdeas = null;
      } else {
        _setErrorState('No se pudieron buscar recetas (Error HTTP ${response.statusCode}).');
      }
    } catch (e) {
      _setErrorState('Error de conexión o traducción. Revisa tu acceso a internet.');
    } finally {
      _setLoadingState(false);
    }
  }
  
  Future<String> traducirTexto(String texto, {String targetLang = 'EN'}) async {
    if (texto.isEmpty || _deepLApiKey.isEmpty) return texto; // Aún es útil para evitar llamadas vacías

    final url = Uri.parse('https://api-free.deepl.com/v2/translate');
    final response = await http.post(url, headers: {'Authorization': 'DeepL-Auth-Key $_deepLApiKey', 'Content-Type': 'application/json'}, body: json.encode({'text': [texto], 'target_lang': targetLang}));

    if (response.statusCode == 200) {
      final translatedData = json.decode(utf8.decode(response.bodyBytes));
      final translations = translatedData['translations'] as List<dynamic>;
      if (translations.isNotEmpty) return translations[0]['text'];
    }
    // Si la traducción falla, lanza una excepción que será capturada por los métodos públicos
    throw Exception('Error al traducir texto (código ${response.statusCode})');
  }

  Future<Map<String, dynamic>> traducirDetallesReceta(Map<String, dynamic> receta) async {
    if (_deepLApiKey.isEmpty) return receta;

    final textosATraducir = <String>[];
    final camposIngredientes = <String>[];
    final camposMedidas = <String>[];
    
    textosATraducir.add(receta['strInstructions'] ?? '');
    for (int i = 1; i <= 20; i++) {
      if (receta['strIngredient$i'] != null && receta['strIngredient$i'].isNotEmpty) {
        textosATraducir.add(receta['strIngredient$i']);
        camposIngredientes.add('strIngredient$i');
      }
      if (receta['strMeasure$i'] != null && receta['strMeasure$i'].isNotEmpty) {
        textosATraducir.add(receta['strMeasure$i']);
        camposMedidas.add('strMeasure$i');
      }
    }

    if (textosATraducir.where((t) => t.isNotEmpty).isEmpty) return receta;
    
    final url = Uri.parse('https://api-free.deepl.com/v2/translate');
    final response = await http.post(url, headers: {'Authorization': 'DeepL-Auth-Key $_deepLApiKey', 'Content-Type': 'application/json'}, body: json.encode({'text': textosATraducir, 'target_lang': 'ES'}));

    if (response.statusCode == 200) {
      final translatedData = json.decode(utf8.decode(response.bodyBytes));
      final translations = translatedData['translations'] as List<dynamic>;
      int transIndex = 0;
      receta['strInstructions'] = translations[transIndex++]['text'];
      for (final _ in camposIngredientes) { receta[camposIngredientes[transIndex-1]] = translations[transIndex++]['text']; }
      for (final _ in camposMedidas) { receta[camposMedidas[transIndex-1-camposIngredientes.length]] = translations[transIndex++]['text']; }
      return receta;
    }
    throw Exception('Error al traducir detalles (código ${response.statusCode})');
  }

  Future<List<dynamic>> _translateRecipeTitles(List<dynamic> recipes) async {
    if (recipes.isEmpty) return recipes;

    final titlesToTranslate = recipes.map((recipe) => recipe['strMeal'] as String).toList();
    final url = Uri.parse('https://api-free.deepl.com/v2/translate');
    final response = await http.post(url, headers: {'Authorization': 'DeepL-Auth-Key $_deepLApiKey','Content-Type': 'application/json'}, body: json.encode({'text': titlesToTranslate, 'target_lang': 'ES'}));

    if (response.statusCode == 200) {
      final translatedData = json.decode(utf8.decode(response.bodyBytes));
      final translations = translatedData['translations'] as List<dynamic>;
      for (int i = 0; i < recipes.length; i++) {
        recipes[i]['strMeal'] = translations[i]['text'];
      }
      return recipes;
    }
    throw Exception('Error al traducir títulos (código ${response.statusCode})');
  }

  bool _checkApiKey() {
    if (_deepLApiKey.isEmpty) {
      _setErrorState('La función de traducción no está disponible. Revisa la configuración de la app.');
      return false;
    }
    return true;
  }

  void _setLoadingState(bool isLoading) {
    _isLoadingIdeas = isLoading;
    if (isLoading) _errorIdeas = null;
    notifyListeners();
  }
  
  void _setErrorState(String error) {
    _ideasComidas = [];
    _errorIdeas = error;
    // --- CORREGIDO: Notificar a los oyentes sobre el estado de error ---
    notifyListeners();
  }
}
