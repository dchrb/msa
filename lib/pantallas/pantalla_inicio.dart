import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:msa/providers/meta1_provider.dart';
import 'package:msa/providers/water_provider.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:msa/providers/medida_provider.dart';
import 'package:msa/providers/meta_provider.dart';

// Pantallas
import 'package:msa/pantallas/pantalla_registro_tabs.dart';
import 'package:msa/pantallas/pantalla_actividad_fisica_tabs.dart';
import 'package:msa/pantallas/pantalla_metas_logros_tabs.dart';
import 'package:msa/pantallas/pantalla_configuracion_tabs.dart';
import 'package:msa/pantallas/pantalla_acerca_de.dart';
import 'package:msa/pantallas/pantalla_perfil.dart';
import 'package:msa/pantallas/pantalla_progreso_dashboard.dart';
import 'package:msa/pantallas/pantalla_dieta_tabs.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    ContenidoInicio(),
    PantallaDietaTabs(),
    PantallaProgresoDashboard(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<InsigniaProvider>(context, listen: false).cargarInsignias();
        Provider.of<MetaProvider>(context, listen: false);
        context.read<InsigniaProvider>().verificarInsigniaExplorador(
              context,
              context.read<WaterProvider>(),
              context.read<FoodProvider>(),
              context.read<MedidaProvider>(),
              context.read<EntrenamientoProvider>(),
            );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0: return 'Inicio';
      case 1: return 'Dieta y Nutrición';
      case 2: return 'Progreso';
      default: return 'Mi Salud Activa';
    }
  }
  
  TabBar _getDietaTabBar(BuildContext context) {
    final theme = Theme.of(context);
    return TabBar(
      labelColor: theme.appBarTheme.foregroundColor,
      unselectedLabelColor: theme.appBarTheme.foregroundColor?.withOpacity(0.7),
      indicatorColor: theme.appBarTheme.foregroundColor,
      tabs: const [
        Tab(icon: Icon(Icons.today), text: 'Menú del Día'),
        Tab(icon: Icon(Icons.calendar_month), text: 'Menú Semanal'),
        Tab(icon: Icon(Icons.lightbulb_outline), text: 'Ideas'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // DefaultTabController envuelve todo para que las pestañas de Dieta funcionen
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle(_selectedIndex)),
          // La barra de pestañas solo aparece si estamos en la sección de Dieta (índice 1)
          bottom: _selectedIndex == 1 ? _getDietaTabBar(context) : null,
        ),
        drawer: _buildDrawer(context), // El menú lateral siempre estará disponible
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Dieta'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progreso'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
  
  // --- MENÚ LATERAL (DRAWER) CON EL DISEÑO DE TU IMAGEN ---
  Widget _buildDrawer(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget _buildDrawerSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    Widget _buildDrawerItem({required IconData icon, required String title, required Widget page}) {
      return ListTile(
        leading: Icon(icon, color: colors.onSurface.withOpacity(0.8)),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              ImageProvider? backgroundImage;
              if (!kIsWeb && profileProvider.imagePath != null && profileProvider.imagePath!.isNotEmpty) {
                backgroundImage = FileImage(File(profileProvider.imagePath!));
              }
              return UserAccountsDrawerHeader(
                accountName: Text(profileProvider.nombre ?? 'Bienvenido', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                accountEmail: const Text("Toca la imagen para editar tu perfil"),
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaPerfil()));
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: colors.surface,
                    backgroundImage: backgroundImage,
                    child: (backgroundImage == null) ? Icon(Icons.person, size: 50, color: colors.primary) : null,
                  ),
                ),
                decoration: BoxDecoration(color: colors.primary),
              );
            },
          ),
          
          _buildDrawerSectionTitle('Registro'),
          _buildDrawerItem(icon: Icons.local_drink, title: 'Registrar Agua', page: const PantallaRegistroTabs(initialIndex: 0)),
          _buildDrawerItem(icon: Icons.restaurant_menu, title: 'Registrar Comidas', page: const PantallaRegistroTabs(initialIndex: 1)),
          _buildDrawerItem(icon: Icons.straighten, title: 'Registrar Medidas', page: const PantallaRegistroTabs(initialIndex: 2)),
          
          const Divider(),
          _buildDrawerSectionTitle('Actividad Física'),
          _buildDrawerItem(icon: Icons.history, title: 'Historial de Entrenamientos', page: const PantallaActividadFisicaTabs(initialIndex: 0)),
          _buildDrawerItem(icon: Icons.menu_book, title: 'Biblioteca de Ejercicios', page: const PantallaActividadFisicaTabs(initialIndex: 1)),

          const Divider(),
          _buildDrawerSectionTitle('Metas y Logros'),
          _buildDrawerItem(icon: Icons.track_changes, title: 'Metas y Logros', page: const PantallaMetasLogrosTabs(initialIndex: 0)),
          _buildDrawerItem(icon: Icons.emoji_events, title: 'Recompensas', page: const PantallaMetasLogrosTabs(initialIndex: 1)),
          
          const Divider(),
          _buildDrawerSectionTitle('Configuración'),
          _buildDrawerItem(icon: Icons.flag, title: 'Configurar Meta Calórica', page: const PantallaConfiguracionTabs(initialIndex: 0)),
          _buildDrawerItem(icon: Icons.notifications, title: 'Recordatorios', page: const PantallaConfiguracionTabs(initialIndex: 1)),
          _buildDrawerItem(icon: Icons.color_lens, title: 'Temas y Configuración', page: const PantallaConfiguracionTabs(initialIndex: 2)),

          const Divider(),
          _buildDrawerItem(icon: Icons.info_outline, title: 'Acerca de', page: const PantallaAcercaDe()),
        ],
      ),
    );
  }
}

// Widget para el contenido del Dashboard de Inicio
class ContenidoInicio extends StatelessWidget {
  const ContenidoInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final waterProvider = context.watch<WaterProvider>();
    final metaProvider = context.watch<Meta1Provider>();
    final foodProvider = context.watch<FoodProvider>();
    final entrenamientoProvider = context.watch<EntrenamientoProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final caloriasHoy = foodProvider.getCaloriasPorFecha(DateTime.now());
    final ultimoEntrenamiento = entrenamientoProvider.sesiones.isNotEmpty
        ? DateFormat('dd MMM', 'es_ES').format(entrenamientoProvider.sesiones.first.fecha)
        : 'No registrado';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profileProvider.nombre != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                '¡Hola, ${profileProvider.nombre}!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          _buildCardResumen(
            context: context,
            title: 'Ingesta de Agua',
            value: '${waterProvider.getIngestaPorFecha(DateTime.now()).toStringAsFixed(0)} ml',
            goal: '${waterProvider.meta.toStringAsFixed(0)} ml',
            icon: Icons.local_drink,
            color: Colors.blue,
          ),
          _buildCardResumen(
            context: context,
            title: 'Calorías de Hoy',
            value: caloriasHoy.toStringAsFixed(0),
            goal: '${metaProvider.metaCalorias} kcal',
            icon: Icons.local_fire_department,
            color: Colors.orange,
          ),
          _buildCardResumen(
            context: context,
            title: 'Último Entrenamiento',
            value: ultimoEntrenamiento,
            goal: '¡A entrenar!',
            icon: Icons.fitness_center,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildCardResumen({
    required BuildContext context,
    required String title,
    required String value,
    required String goal,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: value,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: title == 'Último Entrenamiento' ? '' : ' de $goal',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}