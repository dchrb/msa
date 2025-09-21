import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/racha_provider.dart';
import 'package:msa/widgets/tarjeta_racha.dart';


class TarjetaRachas extends StatelessWidget {
  const TarjetaRachas({super.key});

  @override
  Widget build(BuildContext context) {
    final rachaProvider = context.watch<RachaProvider>();
    final rachasActivas = rachaProvider.rachas
        .where((racha) => racha.rachaActual > 0)
        .toList();
        
    final theme = Theme.of(context);

    if (rachasActivas.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              "¡Empieza un nuevo hábito para ver tus rachas aquí!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            "Mis Rachas Activas",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180, // Altura del carrusel
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: rachasActivas.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: TarjetaRacha(racha: rachasActivas[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
