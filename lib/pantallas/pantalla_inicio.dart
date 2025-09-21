import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/racha_provider.dart';
import 'package:msa/providers/consumo_provider.dart';
import 'package:msa/providers/water_provider.dart';
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:msa/widgets/anillos_progreso.dart';
import 'package:msa/widgets/tarjeta_racha.dart';
import 'package:msa/widgets/screen_watermark.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final consumoProvider = context.watch<ConsumoProvider>();
    final waterProvider = context.watch<WaterProvider>();
    final entrenamientoProvider = context.watch<EntrenamientoProvider>();
    final rachaProvider = context.watch<RachaProvider>();

    final caloriasConsumidas = consumoProvider.caloriasConsumidasHoy;
    final metaCalorias = consumoProvider.metaCaloricaDiaria;
    
    final aguaConsumida = waterProvider.consumoTotalHoy;
    final metaAgua = waterProvider.metaDiaria;
    
    final minutosEntrenamiento = entrenamientoProvider.minutosEntrenadosHoy;
    final metaEntrenamiento = entrenamientoProvider.metaMinutosDiaria;

    final rachasActivas = rachaProvider.rachas.where((r) => r.rachaActual > 0).toList();

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnillosProgreso(
                  caloriasConsumidas: caloriasConsumidas.toDouble(),
                  metaCalorias: metaCalorias.toDouble(),
                  aguaConsumida: aguaConsumida,
                  metaAgua: metaAgua,
                  minutosEjercicio: minutosEntrenamiento.toInt(),
                  metaMinutosEjercicio: metaEntrenamiento.toInt(),
                ),
                const SizedBox(height: 32),

                _buildQuickAccessButtons(context),
                const SizedBox(height: 32),

                if (rachasActivas.isNotEmpty)
                  _buildRachasSection(context, rachasActivas),

              ],
            ),
          ),

          const ScreenWatermark(
            imagePath: 'assets/images/luna_inicio.png',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Comida'),
            onPressed: () {
              // TODO: Navegar a la pantalla de registro de comida
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.local_drink),
            label: const Text('Agua'),
            onPressed: () {
               // TODO: Navegar a la pantalla de registro de agua
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRachasSection(BuildContext context, List<RachaCompuesta> rachas) {
    rachas.sort((a, b) => b.rachaActual.compareTo(a.rachaActual));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rachas Activas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: rachas.length > 5 ? 5 : rachas.length,
            itemBuilder: (context, index) {
              return TarjetaRacha(racha: rachas[index]);
            },
             separatorBuilder: (context, index) => const SizedBox(width: 12),
          ),
        ),
      ],
    );
  }
}
