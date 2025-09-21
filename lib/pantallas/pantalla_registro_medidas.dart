import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:msa/providers/medida_provider.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:msa/providers/insignia_provider.dart';

class PantallaRegistroMedidas extends StatefulWidget {
  const PantallaRegistroMedidas({super.key});

  @override
  State<PantallaRegistroMedidas> createState() => _PantallaRegistroMedidasState();
}

class _PantallaRegistroMedidasState extends State<PantallaRegistroMedidas> {
  final Map<String, TextEditingController> _controllers = {
    'Peso': TextEditingController(),
    'Pecho': TextEditingController(),
    'Brazo': TextEditingController(),
    'Cintura': TextEditingController(),
    'Caderas': TextEditingController(),
    'Muslo': TextEditingController(),
  };

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _guardarMedidas() {
    final medidaProvider = context.read<MedidaProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final now = DateTime.now();
    
    final Map<String, double> nuevasMedidas = {};

    _controllers.forEach((tipo, controller) {
      final valor = double.tryParse(controller.text);
      if (valor != null && valor > 0) {
        nuevasMedidas[tipo.toLowerCase()] = valor;
      }
    });

    if (nuevasMedidas.isNotEmpty) {
      // 1. Guardar las medidas
      medidaProvider.agregarMedidas(nuevasMedidas, now);

      // 2. Actualizar perfil si es necesario
      if (nuevasMedidas.containsKey('peso')) {
        profileProvider.actualizarPesoActual(nuevasMedidas['peso']!);
      }
      
      // 3. Disparar lógica de gamificación
      final insigniaProvider = context.read<InsigniaProvider>();
      insigniaProvider.verificarInsigniasPorMedidas(nuevasMedidas.length);
      // ----------------------------------------

      for (var controller in _controllers.values) {
        controller.clear();
      }
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${nuevasMedidas.length} registro(s) de medida guardado(s).'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No has ingresado ningún valor para guardar.'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Registra tus medidas corporales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa solo los valores que quieras registrar hoy. El peso es el más importante.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            ..._controllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  controller: entry.value,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '${entry.key} (${entry.key == 'Peso' ? 'kg' : 'cm'})',
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar Medidas'),
              onPressed: _guardarMedidas,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
