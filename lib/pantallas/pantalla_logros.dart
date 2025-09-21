import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/insignia_provider.dart';

class PantallaLogros extends StatelessWidget {
  const PantallaLogros({super.key});

  @override
  Widget build(BuildContext context) {
    final insigniaProvider = context.watch<InsigniaProvider>();
    final todasLasInsignias = insigniaProvider.insignias;

    // Agrupar insignias por categoría
    final Map<String, List<InsigniaCompuesta>> insigniasPorCategoria = {};
    for (final insignia in todasLasInsignias) {
      final categoria = insignia.definicion.categoria;
      if (!insigniasPorCategoria.containsKey(categoria)) {
        insigniasPorCategoria[categoria] = [];
      }
      insigniasPorCategoria[categoria]!.add(insignia);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logros y Recompensas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: insigniasPorCategoria.keys.length,
        itemBuilder: (context, index) {
          final categoria = insigniasPorCategoria.keys.elementAt(index);
          final insigniasDeCategoria = insigniasPorCategoria[categoria]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
                child: Text(
                  categoria,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: insigniasDeCategoria.length,
                itemBuilder: (context, gridIndex) {
                  final insignia = insigniasDeCategoria[gridIndex];
                  return _buildInsigniaCard(context, insignia);
                },
              ),
              if (index < insigniasPorCategoria.keys.length - 1)
                const Divider(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInsigniaCard(BuildContext context, InsigniaCompuesta insignia) {
    final bool isConseguida = insignia.obtenida;
    final colorIcono = isConseguida ? Theme.of(context).colorScheme.primary : Colors.grey.shade400;
    final opacidad = isConseguida ? 1.0 : 0.6;

    return Opacity(
      opacity: opacidad,
      child: Card(
        elevation: isConseguida ? 3 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(insignia.icono, size: 40, color: colorIcono),
              const SizedBox(height: 8),
              Text(
                insignia.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                isConseguida ? "¡Conseguido!" : insignia.descripcion,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
