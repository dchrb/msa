import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:msa/firebase_options.dart';

import 'package:msa/pantallas/pantalla_splash.dart';
import 'package:msa/models/recordatorio.dart';
import 'package:msa/models/medida.dart';
import 'package:msa/models/agua.dart';
import 'package:msa/models/alimento.dart';
import 'package:msa/models/plato.dart';
import 'package:msa/models/ejercicio.dart';
import 'package:msa/models/tipo_ejercicio.dart';
import 'package:msa/models/serie.dart';
import 'package:msa/models/detalle_ejercicio.dart';
import 'package:msa/models/sesion_entrenamiento.dart';
import 'package:msa/models/comida_planificada.dart';
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:msa/providers/water_provider.dart';
import 'package:msa/providers/recordatorio_provider.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:msa/providers/meta_provider.dart';
import 'package:msa/providers/meta1_provider.dart';
import 'package:msa/providers/theme_provider.dart';
import 'package:msa/providers/medida_provider.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:msa/providers/dieta_provider.dart';
import 'package:msa/providers/nutricion_provider.dart';
import 'package:msa/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  
  Hive.registerAdapter(RecordatorioAdapter());
  Hive.registerAdapter(MedidaAdapter());
  Hive.registerAdapter(AguaAdapter());
  Hive.registerAdapter(AlimentoAdapter());
  Hive.registerAdapter(PlatoAdapter());
  Hive.registerAdapter(TipoPlatoAdapter());
  Hive.registerAdapter(EjercicioAdapter());
  Hive.registerAdapter(TipoEjercicioAdapter());
  Hive.registerAdapter(DetalleEjercicioAdapter());
  Hive.registerAdapter(SerieAdapter());
  Hive.registerAdapter(SesionEntrenamientoAdapter());
  Hive.registerAdapter(ComidaPlanificadaAdapter());

  await Hive.openBox<Recordatorio>('recordatoriosBox');
  await Hive.openBox<Medida>('medidasBox');
  await Hive.openBox<Agua>('aguaBox');
  await Hive.openBox<Plato>('platosBox');
  await Hive.openBox<Ejercicio>('ejerciciosBox');
  await Hive.openBox<SesionEntrenamiento>('sesionesBox');
  await Hive.openBox<ComidaPlanificada>('comidasPlanificadasBox');
  await Hive.openBox('metaBox');
  await Hive.openBox<Alimento>('alimentosManualesBox');
  
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => MedidaProvider()),
        ChangeNotifierProvider(create: (_) => EntrenamientoProvider()),
        ChangeNotifierProvider(create: (_) => RecordatorioProvider()),
        ChangeNotifierProvider(create: (_) => InsigniaProvider()),
        ChangeNotifierProvider(create: (_) => MetaProvider()),
        ChangeNotifierProvider(create: (_) => Meta1Provider()),
        ChangeNotifierProvider(create: (_) => DietaProvider()),
        ChangeNotifierProvider(create: (_) => NutricionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          
          final colorPrimario = themeProvider.primaryColor;

          final themeClaro = ThemeData(
            useMaterial3: true,
            primaryColor: colorPrimario,
            colorScheme: ColorScheme.light(
              primary: colorPrimario,
              secondary: Colors.blueGrey,
              onPrimary: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: colorPrimario,
              foregroundColor: Colors.white,
            ),
          );

          final themeOscuro = ThemeData(
            useMaterial3: true,
            primaryColor: colorPrimario,
            colorScheme: ColorScheme.dark(
              primary: colorPrimario,
              secondary: Colors.blueGrey.shade200,
              onPrimary: Colors.white,
            ),
             appBarTheme: AppBarTheme(
              backgroundColor: colorPrimario,
              foregroundColor: Colors.white,
            ),
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mi Salud Activa',
            themeMode: themeProvider.themeMode,
            theme: themeClaro,
            darkTheme: themeOscuro,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [ Locale('es', 'ES') ],
            home: const PantallaSplash(),
          );
        },
      ),
    );
  }
}