
import 'dart:math';
import 'package:flutter/material.dart';

class AnillosProgreso extends StatelessWidget {
  final double caloriasConsumidas;
  final double metaCalorias;
  final double aguaConsumida;
  final double metaAgua;
  final int minutosEjercicio;
  final int metaMinutosEjercicio;

  const AnillosProgreso({
    super.key,
    required this.caloriasConsumidas,
    required this.metaCalorias,
    required this.aguaConsumida,
    required this.metaAgua,
    required this.minutosEjercicio,
    this.metaMinutosEjercicio = 30, // Meta por defecto de 30 mins
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Calcula los porcentajes de progreso, asegurándose de no exceder el 100% para el anillo
    final double progresoCalorias = min(caloriasConsumidas / (metaCalorias > 0 ? metaCalorias : 1), 1.0);
    final double progresoAgua = min(aguaConsumida / (metaAgua > 0 ? metaAgua : 1), 1.0);
    final double progresoEjercicio = min(minutosEjercicio / (metaMinutosEjercicio > 0 ? metaMinutosEjercicio : 1), 1.0);

    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: CustomPaint(
          painter: AnilloPainter(
            progresoCalorias: progresoCalorias,
            progresoAgua: progresoAgua,
            progresoEjercicio: progresoEjercicio,
            colorAnilloCalorias: Colors.orange,
            colorAnilloAgua: Colors.blue,
            colorAnilloEjercicio: Colors.green,
            colorFondo: theme.colorScheme.onSurface.withAlpha(26),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange),
              Text(
                '${caloriasConsumidas.toStringAsFixed(0)} Kcal',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'de ${metaCalorias.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnilloPainter extends CustomPainter {
  final double progresoCalorias;
  final double progresoAgua;
  final double progresoEjercicio;
  final Color colorAnilloCalorias;
  final Color colorAnilloAgua;
  final Color colorAnilloEjercicio;
  final Color colorFondo;

  AnilloPainter({
    required this.progresoCalorias,
    required this.progresoAgua,
    required this.progresoEjercicio,
    required this.colorAnilloCalorias,
    required this.colorAnilloAgua,
    required this.colorAnilloEjercicio,
    required this.colorFondo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const grosorAnillo = 12.0;
    final centro = Offset(size.width / 2, size.height / 2);

    void dibujarAnillo(double radio, double progreso, Color color) {
      final paintFondo = Paint()
        ..color = colorFondo
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosorAnillo
        ..strokeCap = StrokeCap.round;

      final paintProgreso = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosorAnillo
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: radio),
        -pi / 2, // Empezar desde arriba
        2 * pi, // Círculo completo para el fondo
        false,
        paintFondo,
      );

      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: radio),
        -pi / 2,
        2 * pi * progreso,
        false,
        paintProgreso,
      );
    }
    
    // Dibujar los tres anillos de fuera hacia adentro
    dibujarAnillo(size.width / 2 - grosorAnillo / 2, progresoCalorias, colorAnilloCalorias);
    dibujarAnillo(size.width / 2 - grosorAnillo * 1.5, progresoAgua, colorAnilloAgua);
    dibujarAnillo(size.width / 2 - grosorAnillo * 2.5, progresoEjercicio, colorAnilloEjercicio);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repintar siempre para animaciones y actualizaciones
  }
}
