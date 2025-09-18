import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:msa/models/alimento.dart';

class NutricionProvider with ChangeNotifier {
  final String _appId = dotenv.env['EDAMAM_APP_ID'] ?? '';
  final String _appKey = dotenv.env['EDAMAM_APP_KEY'] ?? '';

  bool isSearching = false;
  List<Alimento> alimentosEncontrados = [];
  String? error;

  Future<void> buscarAlimentos(String busqueda) async {
    isSearching = true;
    alimentosEncontrados.clear();
    error = null;
    notifyListeners();

    if (_appId.isEmpty || _appKey.isEmpty) {
      error = "Claves de API no configuradas en .env";
      isSearching = false;
      notifyListeners();
      return;
    }
    final url = Uri.parse('https://api.edamam.com/api/food-database/v2/parser?app_id=$_appId&app_key=$_appKey&ingr=${Uri.encodeComponent(busqueda)}&nutrition-type=logging');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hints = data['hints'] as List<dynamic>;
        for (var item in hints) {
          final food = item['food'];
          alimentosEncontrados.add(
            Alimento(
              nombre: food['label'],
              idApi: food['foodId'],
              calorias: (food['nutrients']['ENERC_KCAL'] ?? 0.0).toDouble(),
              proteinas: (food['nutrients']['PROCNT'] ?? 0.0).toDouble(),
              carbohidratos: (food['nutrients']['CHOCDF'] ?? 0.0).toDouble(),
              grasas: (food['nutrients']['FAT'] ?? 0.0).toDouble(),
              porcionGramos: 100,
            )
          );
        }
      } else {
        error = "Error de API.";
      }
    } catch (e) {
      error = "Error de conexión.";
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }
  
  Future<Alimento?> getInfoNutricional(String foodId, double cantidadGramos) async {
    if (_appId.isEmpty || _appKey.isEmpty) return null;
    final url = Uri.parse('https://api.edamam.com/api/food-database/v2/nutrients?app_id=$_appId&app_key=$_appKey');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "ingredients": [{"quantity": cantidadGramos, "measureURI": "http://www.edamam.com/ontologies/edamam.owl#Measure_gram", "foodId": foodId}]
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nutrientes = data['totalNutrients'];
        return Alimento(
          idApi: foodId,
          nombre: data['ingredients'][0]['parsed'][0]['food'],
          calorias: (nutrientes['ENERC_KCAL']?['quantity'] ?? 0.0).toDouble(),
          proteinas: (nutrientes['PROCNT']?['quantity'] ?? 0.0).toDouble(),
          carbohidratos: (nutrientes['CHOCDF']?['quantity'] ?? 0.0).toDouble(),
          grasas: (nutrientes['FAT']?['quantity'] ?? 0.0).toDouble(),
          porcionGramos: cantidadGramos,
        );
      }
    } catch (e) {
      print("Error obteniendo nutrientes: $e");
    }
    return null;
  }
}