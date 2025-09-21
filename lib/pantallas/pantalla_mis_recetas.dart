// lib/pantallas/pantalla_mis_recetas.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/receta_provider.dart';
import 'package:msa/models/receta.dart';
import 'package:msa/pantallas/pantalla_crear_receta.dart';

class PantallaMisRecetas extends StatelessWidget {
  const PantallaMisRecetas({super.key});

  @override
  Widget build(BuildContext context) {
    final recetaProvider = context.watch<RecetaProvider>();
    final recetas = recetaProvider.recetas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recetas'),
      ),
      body: Stack(
        children: [
          if (recetas.isEmpty)
            Center(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset('assets/images/Luna_dieta.png', width: 200),
              ),
            ),
          recetas.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Aún no tienes recetas.\n\n¡Guarda ideas de la comunidad o crea la tuya propia con el botón de abajo!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.5),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: recetas.length,
                  itemBuilder: (context, index) {
                    final receta = recetas[index];
                    return _buildRecipeCard(context, receta, recetaProvider);
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const PantallaCrearReceta()));
        },
        tooltip: 'Crear nueva receta',
        icon: const Icon(Icons.add),
        label: const Text('Crear Receta'),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Receta receta, RecetaProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 3,
      clipBehavior: Clip.antiAlias, // Para que el borde redondeado afecte a la imagen
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        // --- PASO 4: Mostrar la imagen de la receta ---
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: receta.imageUrl != null && receta.imageUrl!.isNotEmpty
              ? Image.network(
                  receta.imageUrl!,
                  width: 50, height: 50, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.restaurant_menu, size: 30),
                )
              : const Icon(Icons.restaurant_menu, size: 30, color: Colors.grey),
        ),
        title: Text(receta.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          // Si los ingredientes no tienen macros, no se muestra 0
          '${receta.alimentos.length} ingredientes',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmarEliminacion(context, receta, provider),
          tooltip: 'Eliminar receta',
        ),
        onTap: () {
          // TODO: Implementar navegación a una pantalla de detalle de la receta propia
          // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => PantallaDetalleMiReceta(receta: receta)));
        },
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, Receta receta, RecetaProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar la receta "${receta.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              provider.eliminarReceta(receta.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Receta "${receta.nombre}" eliminada.'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
