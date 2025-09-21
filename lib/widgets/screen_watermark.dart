
import 'package:flutter/material.dart';

class ScreenWatermark extends StatelessWidget {
  final String imagePath;
  final double size;
  final double opacity;
  final Alignment alignment;

  const ScreenWatermark({
    super.key,
    required this.imagePath,
    this.size = 120.0,
    this.opacity = 0.25,
    this.alignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            // Ignoramos el widget para eventos de puntero para que no bloquee los clics.
            semanticLabel: 'Marca de agua de la pantalla',
          ),
        ),
      ),
    );
  }
}
