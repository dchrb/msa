import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import 'package:msa/models/medida.dart';
import 'package:msa/providers/medida_provider.dart';
import 'package:msa/providers/profile_provider.dart';

class PantallaHistorialMedidas extends StatefulWidget {
  const PantallaHistorialMedidas({super.key});

  @override
  State<PantallaHistorialMedidas> createState() => _PantallaHistorialMedidasState();
}

class _PantallaHistorialMedidasState extends State<PantallaHistorialMedidas> {

  @override
  Widget build(BuildContext context) {
    final medidaProvider = context.watch<MedidaProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    
    if (!medidaProvider.isInitialized || profileProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Historial y Progreso')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final registros = medidaProvider.registros;
    final registrosPorTipo = groupBy(registros, (Medida m) => m.tipo.toLowerCase());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial y Progreso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResumenGeneral(context, profileProvider),
            const SizedBox(height: 24),
            if (registros.length < 2)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Necesitas al menos 2 registros para ver tu progreso.'),
              ))
            else ...[
              _buildSeccionGrafico(registrosPorTipo),
              const SizedBox(height: 24),
              _buildHistorialCompleto(registros, medidaProvider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResumenGeneral(BuildContext context, ProfileProvider profileProvider) {
    final profile = profileProvider.profile;
    if (profile == null) return const SizedBox.shrink();

    final imc = profileProvider.imc;
    final pesoActual = profile.currentWeight;
    final metaPeso = profile.weightGoal;
    final diferenciaMeta = metaPeso != null ? pesoActual - metaPeso : null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          children: [
            Text("Tu Progreso General", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStat("Peso Actual", pesoActual, "kg", color: Theme.of(context).colorScheme.primary),
                if (imc != null) _buildStat("IMC", imc, profileProvider.imcInterpretation, color: _getImcColor(profileProvider.imcInterpretation)),
              ],
            ),
            if (metaPeso != null && diferenciaMeta != null) ...[
              const Divider(height: 30, thickness: 1, indent: 16, endIndent: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat("Meta", metaPeso, "kg"),
                  _buildStat(
                    diferenciaMeta == 0 ? "¡Conseguido!" : "Te Falta", 
                    diferenciaMeta.abs(), 
                    "kg", 
                    color: diferenciaMeta > 0 ? Colors.green : Colors.orangeAccent
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Color _getImcColor(String interpretation) {
    switch (interpretation) {
      case "Bajo peso": return Colors.blueAccent;
      case "Peso saludable": return Colors.green;
      case "Sobrepeso": return Colors.orangeAccent;
      case "Obesidad": return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  Widget _buildStat(String label, double value, String unit, {Color? color}) {
    final valueString = value.toStringAsFixed(1);
    final isSpecialLabel = label == "¡Conseguido!" || label == "Te Falta";

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          if (!isSpecialLabel || value != 0)
            Text("$valueString ${label == 'IMC' ? '' : unit}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          if (label == 'IMC' || isSpecialLabel)
            Text(unit, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.normal))
        ],
      ),
    );
  }
}

// Stubs para los widgets no modificados. Sintaxis corregida aquí.
extension on _PantallaHistorialMedidasState {
    Widget _buildSeccionGrafico(Map<String, List<Medida>> registrosPorTipo) => const SizedBox.shrink();
    Widget _buildHistorialCompleto(List<Medida> registros, MedidaProvider medidaProvider) => const SizedBox.shrink();
}
