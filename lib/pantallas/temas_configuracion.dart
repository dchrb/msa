// lib/pantallas/temas_configuracion.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/theme_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:msa/providers/insignia_provider.dart';

class TemasConfiguracion extends StatelessWidget {
  const TemasConfiguracion({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // <-- LÍNEA AÑADIDA
        title: const Text('Temas y Colores'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text('Tema oscuro', style: TextStyle(fontSize: 18)),
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                    context.read<InsigniaProvider>().otorgarInsignia('personalizador_1', context);
                  },
                ),
              ),
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                'Selecciona un color principal:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ColorPicker(
                pickerColor: themeProvider.primaryColor,
                onColorChanged: (color) {
                  themeProvider.setPrimaryColor(color);
                  context.read<InsigniaProvider>().otorgarInsignia('personalizador_1', context);
                },
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false,
                displayThumbColor: true,
                paletteType: PaletteType.hueWheel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}