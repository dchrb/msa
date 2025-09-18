// lib/pantallas/pantalla_acerca_de.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PantallaAcercaDe extends StatefulWidget {
  const PantallaAcercaDe({super.key});

  @override
  State<PantallaAcercaDe> createState() => _PantallaAcercaDeState();
}

class _PantallaAcercaDeState extends State<PantallaAcercaDe> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InsigniaProvider>().verificarInsigniaCurioso(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de Mi Salud Activa'),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
        titleTextStyle: TextStyle(color: colors.onPrimary, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mi Salud Activa',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu compañero de bienestar personal.',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta aplicación fue creada para ayudarte a tomar el control de tu salud y bienestar. Creemos que el progreso constante, por pequeño que sea, es la clave para un estilo de vida más saludable y activo.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            
            Text(
              'Funcionalidades',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(context, Icons.fitness_center, 'Seguimiento de Entrenamientos'),
            _buildFeatureRow(context, Icons.fastfood, 'Control de Nutrición e Hidratación'),
            _buildFeatureRow(context, Icons.show_chart, 'Visualización de Progreso y Metas'),
            _buildFeatureRow(context, Icons.emoji_events, 'Recompensas para mantener la motivación'),
            
            const SizedBox(height: 24),

            Text(
              'Contacto y Comentarios',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Tienes alguna sugerencia, idea, o encontraste un error? ¡Me encantaría oírte!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('misaludactiva373@gmail.com'),
              onTap: () => _launchUrl('mailto:misaludactiva373@gmail.com'),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('+56964022892'),
              onTap: () => _launchUrl('tel:+56964022892'),
            ),
            ListTile(
              leading: const Icon(Icons.link, color: Colors.purple),
              title: const Text('Instagram'),
              onTap: () => _launchUrl('https://www.instagram.com/msa37_3'),
            ),
            ListTile(
              leading: const Icon(Icons.facebook, color: Colors.blue),
              title: const Text('Facebook'),
              onTap: () => _launchUrl('https://www.facebook.com/profile.php?id=61580423445819'),
            ),
            
            const SizedBox(height: 24),

            Center(
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(color: colors.onSurface),
              ),
            ),
            Center(
              child: Text(
                '© 2025 Mi Salud Activa',
                style: TextStyle(color: colors.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
  
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'No se pudo abrir $url';
    }
  }
}