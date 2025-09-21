// lib/pantallas/ideas_de_comida.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/dieta_provider.dart';
import 'package:msa/providers/receta_provider.dart';
import 'package:msa/pantallas/pantalla_detalle_receta.dart';

class IdeasDeComida extends StatefulWidget {
  const IdeasDeComida({super.key});

  @override
  State<IdeasDeComida> createState() => _IdeasDeComidaState();
}

class _IdeasDeComidaState extends State<IdeasDeComida> {
  String _categoriaSeleccionada = "Beef";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DietaProvider>().fetchIdeasComidas(categoria: _categoriaSeleccionada);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchSubmitted(String query) async {
    final dietaProvider = Provider.of<DietaProvider>(context, listen: false);
    final translatedQuery = await dietaProvider.traducirTexto(query, targetLang: 'EN');
    if (translatedQuery.isNotEmpty) {
      dietaProvider.buscarRecetasPorNombre(translatedQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildControls(context),
        Expanded(
          child: Consumer<DietaProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingIdeas) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.errorIdeas != null) {
                return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(provider.errorIdeas!, textAlign: TextAlign.center)));
              }
              if (provider.ideasComidas.isEmpty) {
                return const Center(child: Text('No se encontraron recetas para esta categoría.'));
              }
              return _buildRecipeList(context, provider.ideasComidas);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    final dietaProvider = context.read<DietaProvider>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Busca una receta por su nombre...',
              hintText: 'Ej: Lasaña, Sopa...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    _onSearchSubmitted(_searchController.text);
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
            onSubmitted: _onSearchSubmitted,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _categoriaSeleccionada,
            decoration: const InputDecoration(labelText: 'O explora por categoría', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: "Beef", child: Text("Carne de Res")),
              DropdownMenuItem(value: "Chicken", child: Text("Pollo")),
              DropdownMenuItem(value: "Pork", child: Text("Cerdo")),
              DropdownMenuItem(value: "Pasta", child: Text("Pasta")),
              DropdownMenuItem(value: "Seafood", child: Text("Pescados y Mariscos")),
              DropdownMenuItem(value: "Breakfast", child: Text("Desayuno")),
              DropdownMenuItem(value: "Dessert", child: Text("Postres")),
              DropdownMenuItem(value: "Vegan", child: Text("Dieta Vegana")),
              DropdownMenuItem(value: "Vegetarian", child: Text("Dieta Vegetariana")),
            ],
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _categoriaSeleccionada = newValue;
                  _searchController.clear();
                });
                dietaProvider.fetchIdeasComidas(categoria: newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(BuildContext context, List<dynamic> recetas) {
    final recetaProvider = context.read<RecetaProvider>();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: recetas.length,
      itemBuilder: (context, index) {
        final receta = recetas[index] as Map<String, dynamic>; // Cast a Map
        final String nombreReceta = receta['strMeal'] ?? 'Sin título';
        final String urlImagen = receta['strMealThumb'] ?? '';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PantallaDetalleReceta(receta: receta))),
            child: Column(
              children: [
                if (urlImagen.isNotEmpty)
                  Image.network(urlImagen, fit: BoxFit.cover, height: 150, width: double.infinity, errorBuilder: (c, e, s) => const SizedBox(height: 150, child: Center(child: Icon(Icons.broken_image, color: Colors.grey)))),
                ListTile(
                  title: Text(nombreReceta, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Idea de TheMealDB'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 30),
                    tooltip: 'Guardar en Mis Recetas',
                    onPressed: () {
                      recetaProvider.agregarRecetaDesdeApi(receta);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("'$nombreReceta' se ha guardado en \"Mis Recetas\""),
                          backgroundColor: Colors.green,
                          action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
