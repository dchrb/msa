import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/models/plato.dart';
import 'package:msa/models/alimento.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:msa/pantallas/pantalla_seleccionar_receta.dart';
import 'package:msa/pantallas/pantalla_registro_plato_avanzado.dart';
import 'package:msa/pantallas/pantalla_mis_alimentos.dart';
import 'package:msa/providers/racha_provider.dart';
import 'package:msa/providers/insignia_provider.dart';

class PantallaComidasHoy extends StatelessWidget {
  const PantallaComidasHoy({super.key});

  void _onPlatoRegistrado(BuildContext context) {
    final rachaProvider = context.read<RachaProvider>();
    final insigniaProvider = context.read<InsigniaProvider>();

    rachaProvider.actualizarRacha('dg_racha_comida_diaria', true);
    insigniaProvider.otorgarInsignia('dg_ins_primera_comida');
    insigniaProvider.otorgarInsignia('dg_ins_10_comidas', cantidad: 1);
  }

  Future<void> _registrarAlimentoComoPlato(BuildContext context, Alimento alimento, TipoPlato tipoPlato) async {
    final foodProvider = context.read<FoodProvider>();
    try {
      await foodProvider.agregarPlato(
        tipo: tipoPlato,
        alimentos: [alimento],
        fecha: DateTime.now(),
      );

      if (context.mounted) {
        _onPlatoRegistrado(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${alimento.nombre} añadido a $tipoPlato.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
       if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir ${alimento.nombre}.'), backgroundColor: Colors.red),
        );
       }
    }
  }

  void _mostrarOpcionesRegistro(BuildContext context, TipoPlato tipoPlato) {
    Navigator.of(context).pop(); // Cierra el primer menú
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: const Text('Añadir desde Mis Recetas'),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PantallaSeleccionarReceta(tipoPlato: tipoPlato)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.kitchen_rounded),
              title: const Text('Añadir desde Mis Alimentos'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final Alimento? alimentoSeleccionado = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PantallaMisAlimentos()),
                );
                if (alimentoSeleccionado != null && context.mounted) {
                  _registrarAlimentoComoPlato(context, alimentoSeleccionado, tipoPlato);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.post_add_rounded),
              title: const Text('Crear Plato Personalizado'),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PantallaRegistroPlatoAvanzado(tipoPlatoInicial: tipoPlato)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarSeleccionDeComida(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Wrap(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('¿Para qué comida quieres registrar?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(title: const Text('Desayuno'), onTap: () => _mostrarOpcionesRegistro(context, TipoPlato.desayuno)),
            ListTile(title: const Text('Almuerzo'), onTap: () => _mostrarOpcionesRegistro(context, TipoPlato.almuerzo)),
            ListTile(title: const Text('Cena'), onTap: () => _mostrarOpcionesRegistro(context, TipoPlato.cena)),
            ListTile(title: const Text('Snack'), onTap: () => _mostrarOpcionesRegistro(context, TipoPlato.snack)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final hoy = DateTime.now();
    final fechaHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final platosHoy = foodProvider.getPlatosPorFecha(fechaHoy);

    if (!foodProvider.isInitialized || profileProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final caloriasConsumidas = foodProvider.getCaloriasConsumidasPorFecha(fechaHoy);
    final metaCalorias = profileProvider.profile?.calorieGoal ?? 2000.0;
    final macros = foodProvider.getMacrosPorFecha(fechaHoy);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildCalorieSummaryCard(context, meta: metaCalorias, consumidas: caloriasConsumidas, macros: macros),
            const SizedBox(height: 16),
            _buildMealCard(context, 'Desayuno', platosHoy.where((p) => p.tipo == TipoPlato.desayuno).toList(), Icons.free_breakfast),
            _buildMealCard(context, 'Almuerzo', platosHoy.where((p) => p.tipo == TipoPlato.almuerzo).toList(), Icons.lunch_dining),
            _buildMealCard(context, 'Cena', platosHoy.where((p) => p.tipo == TipoPlato.cena).toList(), Icons.dinner_dining),
            _buildMealCard(context, 'Snacks', platosHoy.where((p) => p.tipo == TipoPlato.snack).toList(), Icons.fastfood),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarSeleccionDeComida(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalorieSummaryCard(BuildContext context, {required double meta, required double consumidas, required Map<String, double> macros}) {
    final restantes = meta - consumidas;
    final double progress = meta > 0 ? (consumidas / meta).clamp(0, 1) : 0;

    return Card(
      elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calorías', style: Theme.of(context).textTheme.titleLarge),
                Text('${consumidas.toStringAsFixed(0)} / ${meta.toStringAsFixed(0)} kcal', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(5)),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerRight, child: Text('Restantes: ${restantes.toStringAsFixed(0)} kcal')),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _macroColumn('Proteínas', macros['proteinas'] ?? 0),
                _macroColumn('Carbs', macros['carbohidratos'] ?? 0),
                _macroColumn('Grasas', macros['grasas'] ?? 0),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _macroColumn(String title, double value) {
    return Column(
      children: [Text(title, style: const TextStyle(color: Colors.grey)), Text('${value.toStringAsFixed(1)}g', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))],
    );
  }

  Widget _buildMealCard(BuildContext context, String title, List<Plato> platos, IconData icon) {
    final double totalCalorias = platos.fold(0.0, (sum, plato) => sum + plato.totalCalorias);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                Text('${totalCalorias.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
            const Divider(height: 24),
            if (platos.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('No has registrado nada aún.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center))
            else
              ...platos.map((plato) {
                final alimentosNombres = plato.alimentos.map((a) => a.nombre).join(', ');
                return ListTile(
                  title: Text(alimentosNombres.isEmpty ? 'Plato personalizado' : alimentosNombres, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text('${plato.totalCalorias.toStringAsFixed(0)} kcal'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PantallaRegistroPlatoAvanzado(plato: plato))),
                  onLongPress: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Eliminar plato"), content: const Text("¿Estás seguro de que quieres eliminar este registro?"), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Cancelar")), TextButton(onPressed: (){context.read<FoodProvider>().eliminarPlato(plato.id); Navigator.pop(context);}, child: const Text("Eliminar"))])),
                  dense: true, visualDensity: VisualDensity.compact,
                );
              }),
          ],
        ),
      ),
    );
  }
}
