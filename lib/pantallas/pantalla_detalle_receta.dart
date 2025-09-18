// lib/pantallas/pantalla_detalle_receta.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/dieta_provider.dart';

class PantallaDetalleReceta extends StatefulWidget {
  final Map<String, dynamic> receta;

  const PantallaDetalleReceta({super.key, required this.receta});

  @override
  State<PantallaDetalleReceta> createState() => _PantallaDetalleRecetaState();
}

class _PantallaDetalleRecetaState extends State<PantallaDetalleReceta> {
  Map<String, dynamic>? _recetaCompleta;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecetaCompleta();
  }

  Future<void> _fetchRecetaCompleta() async {
    final mealId = widget.receta['idMeal'];
    final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId");
    
    final dietaProvider = Provider.of<DietaProvider>(context, listen: false);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final recetaSinTraducir = data['meals'][0];
          final recetaTraducida = await dietaProvider.traducirDetallesReceta(recetaSinTraducir);
          setState(() {
            _recetaCompleta = recetaTraducida;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.receta['strMeal'] ?? 'Cargando...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_recetaCompleta == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.receta['strMeal'] ?? 'Error'),
        ),
        body: const Center(child: Text('No se pudo cargar la información completa de la receta.')),
      );
    }

    final String nombreReceta = _recetaCompleta!['strMeal'] ?? 'Sin título';
    final String urlImagen = _recetaCompleta!['strMealThumb'] ?? '';
    final String urlYoutube = _recetaCompleta!['strYoutube'] ?? '';
    
    List<String> _getIngredientes() {
      List<String> ingredientes = [];
      for (int i = 1; i <= 20; i++) {
        final ingrediente = _recetaCompleta!['strIngredient$i'];
        final medida = _recetaCompleta!['strMeasure$i'];
        if (ingrediente != null && ingrediente.isNotEmpty && ingrediente.trim().isNotEmpty) {
          ingredientes.add('$medida $ingrediente');
        }
      }
      return ingredientes;
    }
    
    final listaIngredientes = _getIngredientes();

    return Scaffold(
      appBar: AppBar(
        title: Text(nombreReceta),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (urlImagen.isNotEmpty)
              Image.network(
                urlImagen,
                fit: BoxFit.cover,
                height: 250,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 250,
                    child: Center(
                      child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreReceta,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 32),
                  Text(
                    'Categoría: ${_recetaCompleta!['strCategory'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Área: ${_recetaCompleta!['strArea'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 32),
                  Text(
                    'Ingredientes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (listaIngredientes.isEmpty)
                    const Text('No hay ingredientes disponibles.')
                  else
                    ...listaIngredientes.map((ingrediente) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('• $ingrediente', style: const TextStyle(fontSize: 16)),
                    )).toList(),
                  
                  const Divider(height: 32),
                  
                  Text(
                    'Instrucciones',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recetaCompleta!['strInstructions'] ?? 'No hay instrucciones disponibles.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (urlYoutube.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                        label: const Text('Ver video en YouTube', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => _launchUrl(urlYoutube),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}