import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/insignia_provider.dart';

class PantallaRecompensas extends StatelessWidget {
  const PantallaRecompensas({super.key});

  String _getCategoryDisplayName(String categoryId) {
    switch (categoryId) {
      case 'DietaGeneral': return 'Registro Diario';
      case 'PlanSemanal': return 'Plan Semanal';
      case 'Recetas': return 'Recetas';
      case 'Actividad': return 'Actividad Física';
      case 'Agua': return 'Hidratación';
      case 'Medidas': return 'Progreso y Medidas';
      default: return 'General';
    }
  }

  @override
  Widget build(BuildContext context) {
    final insigniaProvider = context.watch<InsigniaProvider>();
    if (insigniaProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final insignias = insigniaProvider.insignias;
    final Map<String, List<InsigniaCompuesta>> insigniasPorCategoria = {};
    for (final insignia in insignias) {
      (insigniasPorCategoria[insignia.definicion.categoria] ??= []).add(insignia);
    }

    final categoriasOrdenadas = ['DietaGeneral', 'PlanSemanal', 'Recetas', 'Actividad', 'Agua', 'Medidas'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recompensas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          for (final categoria in categoriasOrdenadas)
            if (insigniasPorCategoria.containsKey(categoria))
              Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ExpansionTile(
                  title: Text(_getCategoryDisplayName(categoria), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 24.0,
                        alignment: WrapAlignment.center,
                        children: insigniasPorCategoria[categoria]!
                            .map((insignia) => _buildInsigniaCard(context, insignia))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildInsigniaCard(BuildContext context, InsigniaCompuesta insignia) {
    final color = insignia.obtenida ? Theme.of(context).colorScheme.primary : Colors.grey;
    final opacity = insignia.obtenida ? 1.0 : 0.6;

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: color.withAlpha(insignia.obtenida ? 38 : 26),
              child: Icon(insignia.icono, size: 35, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              insignia.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              insignia.descripcion,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey[600]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
