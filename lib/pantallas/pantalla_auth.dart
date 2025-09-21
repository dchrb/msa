import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/sync_provider.dart';

class PantallaAuth extends StatelessWidget {
  const PantallaAuth({super.key});

  @override
  Widget build(BuildContext context) {
    final syncProvider = context.read<SyncProvider>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.shield_outlined,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Bienvenido a MSA',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Inicia sesión para sincronizar tu progreso en la nube o continúa como invitado.',
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),

              // --- Opción 1: Iniciar Sesión con Google ---
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                label: const Text('Iniciar Sesión con Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  await syncProvider.signInWithGoogle();
                  // El AuthWrapper se encargará de la navegación si el login es exitoso
                },
              ),
              const SizedBox(height: 16),

              // --- Opción 2: Continuar como Invitado ---
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  // Llama al método para inicio de sesión anónimo (que añadiremos)
                  final success = await syncProvider.signInAnonymously();
                  if (success == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al iniciar como invitado')),
                    );
                  }
                  // El AuthWrapper se encargará de la navegación si el login es exitoso
                },
                child: const Text('Continuar como Invitado'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
