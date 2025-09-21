import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:msa/providers/insignia_provider.dart';
import 'package:msa/pantallas/pantalla_logros.dart';

class SeccionRecompensas extends StatelessWidget {
  final String categoria;

  const SeccionRecompensas({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    final insigniaProvider = context.watch<InsigniaProvider>();
    final insigniasDeCategoria = insigniaProvider.insignias
        .where((i) => i.definicion.categoria == categoria)
        .toList();

    if (insigniasDeCategoria.isEmpty) {
      return const SizedBox.shrink();
    }

    List<InsigniaCompuesta> vistaPrevia = insigniasDeCategoria
        .where((i) => i.obtenida)
        .toList();

    String tituloSeccion = "Últimas Recompensas Obtenidas";

    if (vistaPrevia.length < 3) {
        final proximas = insigniasDeCategoria.where((i) => !i.obtenida).toList();
        vistaPrevia.addAll(proximas);
        tituloSeccion = "Desafíos de la Categoría";
    }
    
    vistaPrevia = vistaPrevia.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recompensas de $categoria', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PantallaLogros()),
              ),
              child: const Text('Ver Todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(tituloSeccion, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (vistaPrevia.isEmpty)
            const Text("¡Pronto aparecerán nuevos desafíos aquí!")
        else
            Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: vistaPrevia.map((insignia) => _buildChipInsignia(context, insignia, insignia.obtenida)).toList(),
            ),
      ],
    );
  }

  Widget _buildChipInsignia(BuildContext context, InsigniaCompuesta insignia, bool obtenida) {
    final colorScheme = Theme.of(context).colorScheme;
    final chip = Chip(
      avatar: Icon(
        insignia.icono,
        size: 18,
        color: obtenida ? colorScheme.primary : colorScheme.onSurface.withAlpha((255 * 0.5).round()),
      ),
      label: Text(insignia.nombre),
      backgroundColor: obtenida ? colorScheme.primaryContainer.withAlpha((255 * 0.4).round()) : colorScheme.surfaceContainerHighest.withAlpha((255 * 0.7).round()),
      side: BorderSide.none,
    );

    return Tooltip(
      message: obtenida ? "¡Conseguido! - ${insignia.descripcion}" : insignia.descripcion,
      child: chip,
    );
  }
}
