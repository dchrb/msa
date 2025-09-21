// lib/pantallas/pantalla_splash.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:msa/pantallas/pantalla_inicio.dart';
import 'package:msa/pantallas/pantalla_onboarding.dart';

class PantallaSplash extends StatefulWidget {
  const PantallaSplash({super.key});

  @override
  State<PantallaSplash> createState() => _PantallaSplashState();
}

class _PantallaSplashState extends State<PantallaSplash> {
  bool _navigationHandled = false; // Flag to prevent multiple navigations

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Observamos el provider. Cuando cambie, este método se volverá a ejecutar.
    final profileProvider = context.watch<ProfileProvider>();
    
    // Si el perfil ya no está cargando y aún no hemos navegado...
    if (!profileProvider.isLoading && !_navigationHandled) {
      _navigationHandled = true; // Marcamos que la navegación se ha manejado.
      
      // Usamos addPostFrameCallback para navegar después de que el widget se construya.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return; // Comprobación de seguridad
        
        if (profileProvider.perfilCreado) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaInicio()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaOnboarding()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // La UI se mantiene igual, mostrando el logo y el texto de carga.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/luna_inicio.png',
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              "Mi Salud Activa",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Cargando tu progreso...",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
