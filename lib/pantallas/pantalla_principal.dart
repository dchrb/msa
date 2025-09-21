import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:msa/pantallas/pantalla_sincronizacion.dart';
import 'package:msa/pantallas/pantallas.dart';
import 'package:msa/widgets/app_drawer.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _selectedIndex = 0;

  // Actualizamos la lista de pantallas para la barra de navegación inferior
  static const List<Widget> _widgetOptions = <Widget>[
    PantallaInicio(),
    PantallaDietaTabs(),
    PantallaProgresoDashboard(),
  ];

  // Actualizamos los títulos correspondientes
  static const List<String> _titles = <String>[
    'Inicio',
    'Dieta',
    'Progreso',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null 
                  ? const Icon(Icons.person_outline, size: 22)
                  : null,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaSincronizacion()),
              );
            },
            tooltip: 'Cuenta y Sincronización',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(), // Mantenemos el menú lateral
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Reconstruimos la barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Dieta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Progreso',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, 
      ),
    );
  }
}
