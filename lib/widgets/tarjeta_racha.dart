import 'package:flutter/material.dart';
import 'package:msa/providers/racha_provider.dart';

class TarjetaRacha extends StatelessWidget {
  final RachaCompuesta racha;

  const TarjetaRacha({super.key, required this.racha});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 150, // Ancho fijo para cada tarjeta en el carrusel
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha((255 * 0.5).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withAlpha((255 * 0.2).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(racha.icono, size: 32, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            '${racha.rachaActual} ${racha.rachaActual > 1 ? 'días' : 'día'}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            racha.nombre,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
