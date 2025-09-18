// lib/pantallas/ideas_de_comida.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/dieta_provider.dart';
import 'package:msa/pantallas/pantalla_detalle_receta.dart'; // Importamos la nueva pantalla

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
                return Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(provider.errorIdeas!, textAlign: TextAlign.center),
                ));
              }
              if (provider.ideasComidas.isEmpty) {
                return const Center(child: Text('No se encontraron recetas.'));
              }
              return _buildRecipeList(provider.ideasComidas);
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
          const Text("O explora por categoría:", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _categoriaSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Selecciona una categoría de comida',
              border: OutlineInputBorder(),
            ),
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

  Widget _buildRecipeList(List<dynamic> recetas) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: recetas.length,
      itemBuilder: (context, index) {
        final receta = recetas[index];
        final String nombreReceta = receta['strMeal'] ?? 'Sin título';
        final String urlImagen = receta['strMealThumb'] ?? '';
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaDetalleReceta(receta: receta)),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (urlImagen.isNotEmpty)
                  Image.network(
                    urlImagen,
                    fit: BoxFit.cover,
                    height: 150,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(height: 150, child: Center(child: Icon(Icons.broken_image)));
                    },
                  ),
                ListTile(
                  title: Text(nombreReceta),
                  subtitle: const Text('Receta de TheMealDB'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}