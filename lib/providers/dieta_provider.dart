// lib/providers/dieta_provider.dart

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:msa/models/comida_planificada.dart';

class DietaProvider with ChangeNotifier {
  final String _deepLApiKey = dotenv.env['DEEPL_API_KEY'] ?? '';

  Map<int, List<ComidaPlanificada>> _menuSemanal = {};
  Map<int, List<ComidaPlanificada>> get menuSemanal => _menuSemanal;

  List<dynamic> _ideasComidas = [];
  bool _isLoadingIdeas = false;
  String? _errorIdeas;
  
  List<dynamic> get ideasComidas => _ideasComidas;
  bool get isLoadingIdeas => _isLoadingIdeas;
  String? get errorIdeas => _errorIdeas;

  DietaProvider() {
    _initMenuSemanal();
  }

  void _initMenuSemanal() {
    for (int i = 1; i <= 7; i++) { _menuSemanal[i] = []; }
    notifyListeners();
  }

  void agregarComidaPlanificada(int dia, ComidaPlanificada comida) {
    if (_menuSemanal.containsKey(dia)) { _menuSemanal[dia]!.add(comida); }
    notifyListeners();
  }

  void eliminarComidaPlanificada(int dia, ComidaPlanificada comida) {
    _menuSemanal[dia]?.removeWhere((p) => p.id == comida.id);
    notifyListeners();
  }

  void marcarComidaComoCompletada(int dia, String comidaId, bool isCompleted) {
    final comida = _menuSemanal[dia]?.firstWhere((c) => c.id == comidaId);
    if (comida != null) {
      comida.completado = isCompleted;
      notifyListeners();
    }
  }

  List<ComidaPlanificada> getMenuDelDia(int dia) {
    return _menuSemanal[dia] ?? [];
  }
  
  Future<void> fetchIdeasComidas({required String categoria}) async {
    _setLoadingState(true);
    if (!_checkApiKey()) return;

    try {
      final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/filter.php?c=$categoria");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _ideasComidas = (data['meals'] != null)
            ? await _translateRecipeTitles(data['meals'] as List<dynamic>)
            : [];
        _errorIdeas = null;
      } else {
        _setErrorState('No se pudieron obtener ideas en este momento.');
      }
    } catch (e) {
      _setErrorState('Error de conexión. Revisa tu acceso a internet.');
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
        _ideasComidas = (data['meals'] != null)
            ? await _translateRecipeTitles(data['meals'] as List<dynamic>)
            : [];
        _errorIdeas = null;
      } else {
        _setErrorState('No se pudieron obtener ideas en este momento.');
      }
    } catch (e) {
      _setErrorState('Error de conexión. Revisa tu acceso a internet.');
    } finally {
      _setLoadingState(false);
    }
  }
  
  Future<String> traducirTexto(String texto, {String targetLang = 'EN'}) async {
    if (texto.isEmpty || _deepLApiKey.isEmpty) return texto;

    final url = Uri.parse('https://api-free.deepl.com/v2/translate');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'DeepL-Auth-Key $_deepLApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'text': [texto], 'target_lang': targetLang}),
      );

      if (response.statusCode == 200) {
        final translatedData = json.decode(utf8.decode(response.bodyBytes));
        final translations = translatedData['translations'] as List<dynamic>;
        if (translations.isNotEmpty) {
          return translations[0]['text'];
        }
      } else {
        print("Error al traducir texto (código ${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Error de conexión con DeepL: $e");
    }
    return texto;
  }

  Future<Map<String, dynamic>> traducirDetallesReceta(Map<String, dynamic> receta) async {
    if (_deepLApiKey.isEmpty) return receta;

    final List<String> textosATraducir = [];
    textosATraducir.add(receta['strInstructions'] ?? '');
    
    final List<String> camposIngredientes = [];
    for (int i = 1; i <= 20; i++) {
      final ingrediente = receta['strIngredient$i'];
      if (ingrediente != null && ingrediente.isNotEmpty) {
        textosATraducir.add(ingrediente);
        camposIngredientes.add('strIngredient$i');
      }
    }
    
    final List<String> camposMedidas = [];
    for (int i = 1; i <= 20; i++) {
      final medida = receta['strMeasure$i'];
      if (medida != null && medida.isNotEmpty) {
        textosATraducir.add(medida);
        camposMedidas.add('strMeasure$i');
      }
    }

    if (textosATraducir.isEmpty) return receta;
    
    final url = Uri.parse('https://api-free.deepl.com/v2/translate');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'DeepL-Auth-Key $_deepLApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'text': textosATraducir, 'target_lang': 'ES'}),
      );

      if (response.statusCode == 200) {
        final translatedData = json.decode(utf8.decode(response.bodyBytes));
        final translations = translatedData['translations'] as List<dynamic>;

        // Traducir instrucciones
        receta['strInstructions'] = translations[0]['text'];

        // Traducir ingredientes
        int index = 1;
        for (final campo in camposIngredientes) {
          receta[campo] = translations[index]['text'];
          index++;
        }
        
        // Traducir medidas
        for (final campo in camposMedidas) {
          receta[campo] = translations[index]['text'];
          index++;
        }
      } else {
        print("Error al traducir detalles (código ${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Error de conexión con DeepL: $e");
    }
    return receta;
  }


  Future<List<dynamic>> _translateRecipeTitles(List<dynamic> recipes) async {
    if (recipes.isEmpty || _deepLApiKey.isEmpty) return recipes;

    final titlesToTranslate = recipes.map((recipe) => recipe['strMeal'] as String).toList();
    final url = Uri.parse('https://api-free.deepl.com/v2/translate');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'DeepL-Auth-Key $_deepLApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'text': titlesToTranslate, 'target_lang': 'ES'}),
      );

      if (response.statusCode == 200) {
        final translatedData = json.decode(utf8.decode(response.bodyBytes));
        final translations = translatedData['translations'] as List<dynamic>;
        for (int i = 0; i < recipes.length; i++) {
          recipes[i]['strMeal'] = translations[i]['text'];
        }
      } else {
        print("Error al traducir títulos (código ${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      print("Error de conexión con DeepL: $e");
    }
    return recipes;
  }

  bool _checkApiKey() {
    if (_deepLApiKey.isEmpty) {
      _setErrorState('Revisa tu clave de API de DeepL en el archivo .env');
      return false;
    }
    return true;
  }

  void _setLoadingState(bool isLoading) {
    _isLoadingIdeas = isLoading;
    if (isLoading) {
      _errorIdeas = null;
    }
    notifyListeners();
  }
  
  void _setErrorState(String error) {
    _ideasComidas = [];
    _errorIdeas = error;
  }
}