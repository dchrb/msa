import 'package:flutter/material.dart';

class PantallaProgresoDashboard extends StatelessWidget {
  const PantallaProgresoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          // Tarjeta en blanco como en la imagen
          SizedBox(
            height: 100, // Altura aproximada
            child: Card(
              elevation: 2,
              child: Center(child: Text('Widget de Resumen Superior')),
            ),
          ),
          SizedBox(height: 24),

          // Tarjeta de Volumen de Entrenamiento
          ProgresoCard(
            title: 'Volumen de Entrenamiento',
            subtitle: '(Últimos 7 días)',
            graphPlaceholder: 'Gráfico de volumen',
            imagePath: 'assets/images/Luna_entrenamiento.png',
          ),
          SizedBox(height: 24),

          // Tarjeta de Ingesta Calórica
          ProgresoCard(
            title: 'Ingesta Calórica',
            subtitle: '(Últimos 7 días)',
            graphPlaceholder: 'Gráfico de calorías',
            imagePath: 'assets/images/Luna_comida.png',
          ),
        ],
      ),
    );
  }
}

// Widget reutilizable para las tarjetas de progreso, replicando el diseño
class ProgresoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String graphPlaceholder;
  final String imagePath;

  const ProgresoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.graphPlaceholder,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text(graphPlaceholder),
            const SizedBox(height: 8),
            // Placeholder para la imagen que no se puede cargar
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Unable to load asset: "$imagePath"',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'Exception: Asset not found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
