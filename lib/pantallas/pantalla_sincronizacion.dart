import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/sync_provider.dart';

class PantallaSincronizacion extends StatelessWidget {
  const PantallaSincronizacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta y Sincronización'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          if (user != null) {
            // --- Vista para usuario con sesión iniciada ---
            return _buildVistaUsuarioLogueado(context, user);
          } else {
            // --- Vista para usuario local o invitado ---
            return _buildVistaInvitado(context);
          }
        },
      ),
    );
  }

  // --- WIDGET PARA USUARIO LOGUEADO ---
  Widget _buildVistaUsuarioLogueado(BuildContext context, User user) {
    final syncProvider = Provider.of<SyncProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(user.displayName ?? 'Usuario', style: Theme.of(context).textTheme.headlineSmall),
            Text(user.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 48),
        ListTile(
          leading: const Icon(Icons.cloud_upload_outlined),
          title: const Text('Copia de Seguridad'),
          subtitle: Text(
            syncProvider.isSyncing
              ? 'Sincronizando...' 
              : 'Última copia: ${syncProvider.lastSyncTime}'
          ),
          trailing: syncProvider.isSyncing
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => syncProvider.syncAllData(),
                  tooltip: 'Forzar sincronización',
                ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              // Vuelve a la pantalla anterior o a la principal
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  // --- WIDGET PARA USUARIO INVITADO / LOCAL ---
  Widget _buildVistaInvitado(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Protege tu progreso',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea una cuenta para guardar tus datos de forma segura en la nube y acceder a ellos desde cualquier dispositivo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Iniciar Sesión con Google'),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: null, // Funcionalidad deshabilitada temporalmente
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: null, // Funcionalidad deshabilitada temporalmente
            child: const Text('Crear cuenta con Email'),
          ),
        ],
      ),
    );
  }
}
