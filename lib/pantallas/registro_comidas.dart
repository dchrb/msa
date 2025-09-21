// lib/pantallas/registro_comidas.dart

import 'package:flutter/material.dart';
import 'package:msa/models/receta.dart';
import 'package:msa/providers/receta_provider.dart';
import 'package:provider/provider.dart';

import 'package:msa/models/plato.dart';
import 'package:msa/providers/food_provider.dart';
// import 'package:msa/providers/insignia_provider.dart';
// import 'package:msa/providers/racha_provider.dart';

class RegistroComidas extends StatefulWidget {
  const RegistroComidas({super.key});

  @override
  State<RegistroComidas> createState() => _RegistroComidasState();
}

class _RegistroComidasState extends State<RegistroComidas> {
  TipoPlato _tipoPlato = TipoPlato.desayuno;

  // void _triggerRewardChecks(Plato plato) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (!mounted) return;
  //     context.read<InsigniaProvider>().verificarYActualizarInsignias(context, 'registro_comida');
  //     context.read<RachaProvider>().verificarRachasPorRegistroDeComida(context, plato);
  //   });
  // }

  // --- NUEVA LÓGICA PARA REGISTRAR DESDE "MIS RECETAS" ---
  Future<void> _mostrarDialogoMisRecetas() async {
    final recetaProvider = context.read<RecetaProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final recetasGuardadas = recetaProvider.recetas;

    if (recetasGuardadas.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("No tienes recetas guardadas en \"Mis Recetas\".")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona una receta'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: recetasGuardadas.length,
              itemBuilder: (context, index) {
                final receta = recetasGuardadas[index];
                return ListTile(
                  title: Text(receta.nombre),
                  subtitle: Text('${receta.totalCalorias.toStringAsFixed(0)} kcal'),
                  onTap: () {
                    _registrarReceta(receta);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ],
        );
      },
    );
  }

  void _registrarReceta(Receta receta) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    context.read<FoodProvider>().agregarPlato(
      tipo: _tipoPlato,
      alimentos: receta.alimentos,
      fecha: DateTime.now(),
    );

    // --- CONEXIÓN CON RECOMPENSAS ---
    // _triggerRewardChecks(plato);

    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text("La receta '${receta.nombre}' se ha registrado."), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<TipoPlato>(
              initialValue: _tipoPlato,
              items: TipoPlato.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo.name.replaceFirst(tipo.name[0], tipo.name[0].toUpperCase())),
                );
              }).toList(),
              onChanged: (tipo) {
                if (tipo != null) setState(() => _tipoPlato = tipo);
              },
              decoration: const InputDecoration(
                labelText: 'Tipo de Comida',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // --- NUEVO BOTÓN PARA RECETAS ---
            ElevatedButton.icon(
              icon: const Icon(Icons.book_outlined),
              label: const Text("Registrar desde Mis Recetas"),
              onPressed: _mostrarDialogoMisRecetas,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(thickness: 1),
            ),
            const Text("O crea un plato nuevo manualmente:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),

            // --- RESTO DE LA PANTALLA (SIN CAMBIOS) ---
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ... (campos de texto para alimento manual)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
