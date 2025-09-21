
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TarjetaPeso extends StatelessWidget {
  final double? ultimoPeso;
  final double? pesoAnterior;
  final DateTime? fechaUltimoPeso;

  const TarjetaPeso({
    super.key,
    this.ultimoPeso,
    this.pesoAnterior,
    this.fechaUltimoPeso,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat('0.0', 'es_ES');

    Widget contenidoInterno;

    if (ultimoPeso == null) {
      contenidoInterno = const Center(
        child: Text('Registra tu peso para empezar', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
      );
    } else {
      String cambio = '--';
      IconData iconoCambio = Icons.remove;
      Color colorCambio = Colors.grey;

      if (pesoAnterior != null) {
        final double diferencia = ultimoPeso! - pesoAnterior!;
        if (diferencia.abs() > 0.05) { // Umbral para considerar un cambio
          cambio = '${diferencia > 0 ? '+' : ''}${formatter.format(diferencia)} kg';
          if (diferencia > 0) {
            iconoCambio = Icons.arrow_upward;
            colorCambio = Colors.red;
          } else {
            iconoCambio = Icons.arrow_downward;
            colorCambio = Colors.green;
          }
        }
      }

      contenidoInterno = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${formatter.format(ultimoPeso)} kg',
            style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (fechaUltimoPeso != null)
            Text(
              'Último registro: ${DateFormat('dd MMM', 'es_ES').format(fechaUltimoPeso!)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconoCambio, color: colorCambio, size: 20),
              const SizedBox(width: 4),
              Text(
                '$cambio desde el anterior',
                style: TextStyle(color: colorCambio, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 120, // Altura fija para consistencia
          child: contenidoInterno,
        ),
      ),
    );
  }
}

