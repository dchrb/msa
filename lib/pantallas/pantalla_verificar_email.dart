
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:msa/pantallas/pantalla_principal.dart';


class PantallaVerificarEmail extends StatefulWidget {
  const PantallaVerificarEmail({super.key});

  @override
  State<PantallaVerificarEmail> createState() => _PantallaVerificarEmailState();
}

class _PantallaVerificarEmailState extends State<PantallaVerificarEmail> {
  bool _isEmailVerified = false;
  bool _canResendEmail = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Comprobar si el email ya está verificado al entrar
    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!_isEmailVerified) {
      // Si no está verificado, enviar un correo de verificación
      _sendVerificationEmail();

      // Iniciar un temporizador para comprobar el estado de verificación cada 3 segundos
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    // Es crucial cancelar el temporizador para evitar fugas de memoria
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    // Recargar los datos del usuario desde Firebase
    await FirebaseAuth.instance.currentUser!.reload();
    if (!mounted) return;

    setState(() {
      _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (_isEmailVerified) {
      _timer?.cancel();
      // Si el email se ha verificado, navega a la pantalla principal
      // y elimina todas las rutas anteriores para que el usuario no pueda volver atrás.
      if(mounted){
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      // Deshabilitar el botón de reenvío por 60 segundos para evitar spam
      if(mounted) setState(() => _canResendEmail = false);
      await Future.delayed(const Duration(seconds: 60));
      if(mounted) {
        setState(() => _canResendEmail = true);
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reenviar el correo: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si el email ya está verificado, muestra la pantalla principal directamente
    return _isEmailVerified
        ? const PantallaPrincipal()
        : Scaffold(
            appBar: AppBar(
              title: const Text("Verifica tu Correo Electrónico"),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Se ha enviado un correo de verificación a:',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      FirebaseAuth.instance.currentUser!.email!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Por favor, revisa tu bandeja de entrada y haz clic en el enlace para activar tu cuenta.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Reenviar Correo'),
                      onPressed: _canResendEmail ? _sendVerificationEmail : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () => FirebaseAuth.instance.signOut(),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
