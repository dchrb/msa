import 'package:flutter/material.dart';
import 'package:msa/pantallas/pantalla_recompensas.dart';
import 'package:msa/pantallas/pantalla_logros.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              // Podríamos usar un color o una imagen que se alinee con el tema
              color: Colors.purple,
            ),
            child: Text(
              'Menú', 
              style: TextStyle(
                color: Colors.white, 
                fontSize: 24,
              ),
            ),
          ),

          _buildSectionTitle(context, 'REGISTRO'),
          _buildDrawerItem(context, icon: Icons.water_drop_outlined, text: 'Registrar Agua', onTap: () { 
            // TODO: Navegar a la pantalla/tab de registro de agua
            Navigator.pop(context);
          }),
          _buildDrawerItem(context, icon: Icons.restaurant_menu_outlined, text: 'Registrar Comidas', onTap: () {
             // TODO: Navegar a la pantalla/tab de registro de comidas
            Navigator.pop(context);
          }),
          _buildDrawerItem(context, icon: Icons.straighten_outlined, text: 'Registrar Medidas', onTap: () {
            // TODO: Navegar a la pantalla/tab de registro de medidas
            Navigator.pop(context);
           }),

          const Divider(),

          _buildSectionTitle(context, 'ACTIVIDAD FÍSICA'),
          _buildDrawerItem(context, icon: Icons.history, text: 'Historial de Entrenamientos', onTap: () { 
            // TODO: Navegar al historial
            Navigator.pop(context);
          }),
          _buildDrawerItem(context, icon: Icons.book_outlined, text: 'Biblioteca de Ejercicios', onTap: () { 
            // TODO: Navegar a la biblioteca
            Navigator.pop(context);
          }),

          const Divider(),

           _buildSectionTitle(context, 'METAS Y LOGROS'),
          _buildDrawerItem(context, icon: Icons.trending_up, text: 'Metas y Logros', onTap: () {
            Navigator.pop(context); // Cierra el drawer
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaLogros()));
          }),
          _buildDrawerItem(context, icon: Icons.emoji_events_outlined, text: 'Recompensas', onTap: () {
            Navigator.pop(context); // Cierra el drawer
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaRecompensas()));
          }),

          const Divider(),

          _buildSectionTitle(context, 'CONFIGURACIÓN'),
           _buildDrawerItem(context, icon: Icons.flag_outlined, text: 'Configurar Meta Calórica', onTap: () { 
            // TODO: Navegar a la configuración de metas
            Navigator.pop(context);
          }),
          _buildDrawerItem(context, icon: Icons.notifications_outlined, text: 'Recordatorios', onTap: () { 
            // TODO: Navegar a la pantalla de recordatorios
            Navigator.pop(context);
          }),
           _buildDrawerItem(context, icon: Icons.palette_outlined, text: 'Temas y Configuración', onTap: () { 
            // TODO: Navegar a la configuración general
            Navigator.pop(context);
          }),
          
          const Divider(),

          _buildDrawerItem(context, icon: Icons.info_outline, text: 'Acerca de', onTap: () { 
            // TODO: Mostrar diálogo de "Acerca de"
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.purple, // Theme.of(context).colorScheme.primary
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color?.withAlpha((255 * 0.7).round())),
      title: Text(text),
      onTap: onTap,
      dense: true,
    );
  }
}
