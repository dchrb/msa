import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:msa/pantallas/pantalla_inicio.dart';
import 'package:msa/pantallas/pantalla_onboarding.dart';
import 'dart:async';

class PantallaSplash extends StatefulWidget {
  const PantallaSplash({super.key});

  @override
  State<PantallaSplash> createState() => _PantallaSplashState();
}

class _PantallaSplashState extends State<PantallaSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      _verificarPerfil();
    });
  }

  Future<void> _verificarPerfil() async {
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.cargarPerfil();

    if (mounted) {
      if (profileProvider.perfilCreado) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaInicio()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaOnboarding()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              "Mi Salud Activa",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}