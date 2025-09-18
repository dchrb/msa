// lib/pantallas/pantalla_configuracion_tabs.dart

import 'package:flutter/material.dart';
import 'package:msa/pantallas/meta_config.dart';
import 'package:msa/pantallas/recordatorios.dart';
import 'package:msa/pantallas/temas_configuracion.dart';

class PantallaConfiguracionTabs extends StatelessWidget {
  final int initialIndex;
  const PantallaConfiguracionTabs({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DefaultTabController(
      initialIndex: initialIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
          bottom: TabBar(
            labelColor: colors.onPrimary,
            unselectedLabelColor: colors.onPrimary.withOpacity(0.7),
            indicatorColor: colors.onPrimary,
            tabs: const [
              // CAMBIO: Se añadió texto a los iconos para mantener la coherencia.
              Tab(icon: Icon(Icons.flag), text: 'Meta'),
              Tab(icon: Icon(Icons.notifications), text: 'Recordatorios'),
              Tab(icon: Icon(Icons.color_lens), text: 'Tema'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MetaConfig(),
            PantallaRecordatorios(),
            TemasConfiguracion(),
          ],
        ),
      ),
    );
  }
}