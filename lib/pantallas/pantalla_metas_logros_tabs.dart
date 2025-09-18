// lib/pantallas/pantalla_metas_logros_tabs.dart

import 'package:flutter/material.dart';
import 'package:msa/pantallas/metas_objetivos.dart';
import 'package:msa/pantallas/recompensas.dart';

class PantallaMetasLogrosTabs extends StatelessWidget {
  final int initialIndex;
  const PantallaMetasLogrosTabs({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DefaultTabController(
      initialIndex: initialIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Metas y Logros'),
          bottom: TabBar(
            labelColor: colors.onPrimary,
            unselectedLabelColor: colors.onPrimary.withOpacity(0.7),
            indicatorColor: colors.onPrimary,
            tabs: const [
              // CAMBIO: Se añadió texto a los iconos para mantener la coherencia.
              Tab(icon: Icon(Icons.track_changes), text: 'Objetivos'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Recompensas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MetasObjetivos(),
            Recompensas(),
          ],
        ),
      ),
    );
  }
}