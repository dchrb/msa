import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:msa/providers/profile_provider.dart';

class PantallaMetas extends StatefulWidget {
  const PantallaMetas({super.key});

  @override
  State<PantallaMetas> createState() => _PantallaMetasState();
}

class _PantallaMetasState extends State<PantallaMetas> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _metaCaloriasController;
  late TextEditingController _metaPesoController;
  double? _caloriasMantenimientoSugeridas;

  @override
  void initState() {
    super.initState();
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;

    _metaCaloriasController = TextEditingController(text: profile?.calorieGoal.toStringAsFixed(0) ?? '2000');
    _metaPesoController = TextEditingController(text: profile?.weightGoal?.toString() ?? '');
    
    // Calculamos las calorías sugeridas al inicio si el perfil está completo
    if (profile != null && profile.age > 0) {
        _caloriasMantenimientoSugeridas = profileProvider.calculateCaloriasRecomendadas();
    }
  }

  void _guardarMetas() {
    if (_formKey.currentState?.validate() ?? false) {
      final profileProvider = context.read<ProfileProvider>();
      
      final metaCalorias = double.tryParse(_metaCaloriasController.text);
      final metaPeso = double.tryParse(_metaPesoController.text);

      profileProvider.guardarMetas(metaCalorias: metaCalorias, metaPeso: metaPeso);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metas actualizadas con éxito.'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    }
  }

  void _sugerirCalorias() {
    final profileProvider = context.read<ProfileProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (profileProvider.profile == null || profileProvider.profile!.age == 0) {
       messenger.showSnackBar(
        const SnackBar(
          content: Text('Completa tu perfil (edad, altura, sexo, etc.) para recibir una sugerencia.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final caloriasSugeridas = profileProvider.calculateCaloriasRecomendadas();
    setState(() {
      _caloriasMantenimientoSugeridas = caloriasSugeridas;
      _metaCaloriasController.text = caloriasSugeridas.round().toString();
    });

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Sugerencia de calorías calculada y aplicada.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _metaCaloriasController.dispose();
    _metaPesoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Metas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSeccionCalorias(context),
              const SizedBox(height: 24),
              _buildSeccionPeso(context),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar Metas'),
                onPressed: _guardarMetas,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionCalorias(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Meta de Calorías", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildSugerenciaCard(context),
        const SizedBox(height: 16),
        TextFormField(
          controller: _metaCaloriasController,
          decoration: const InputDecoration(
            labelText: 'Mi Meta de Calorías (kcal)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || v.isEmpty || (double.tryParse(v) ?? 0) <= 0) ? 'Ingresa calorías válidas' : null,
        ),
        if (_caloriasMantenimientoSugeridas != null) ...[
          const SizedBox(height: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _metaCaloriasController,
            builder: (context, value, child) {
              final metaActual = double.tryParse(value.text) ?? 0;
              final diferencia = metaActual - _caloriasMantenimientoSugeridas!;
              String textoDiferencia;
              Color colorDiferencia = Colors.grey;
              if (diferencia == 0) {
                textoDiferencia = "Estás en mantenimiento.";
              } else if (diferencia > 0) {
                textoDiferencia = "Superávit de ${diferencia.toStringAsFixed(0)} kcal";
                colorDiferencia = Colors.orangeAccent;
              } else {
                textoDiferencia = "Déficit de ${(-diferencia).toStringAsFixed(0)} kcal";
                colorDiferencia = Colors.green;
              }
              return Text(textoDiferencia, style: TextStyle(color: colorDiferencia, fontWeight: FontWeight.bold));
            },
          )
        ]
      ],
    );
  }

  Widget _buildSugerenciaCard(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    final profileCompleto = profileProvider.profile != null && profileProvider.profile!.age > 0;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profileCompleto && _caloriasMantenimientoSugeridas != null)
              Text(
                "Tus calorías de mantenimiento estimadas son: ${_caloriasMantenimientoSugeridas!.toStringAsFixed(0)} kcal",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              )
            else 
              const Text(
                "Calcula tus calorías de mantenimiento recomendadas según los datos de tu perfil.",
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(profileCompleto ? "Re-calcular y aplicar" : "Calcular y aplicar"),
              onPressed: _sugerirCalorias,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionPeso(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Meta de Peso", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextFormField(
          controller: _metaPesoController,
          decoration: const InputDecoration(
            labelText: 'Mi Meta de Peso (kg)',
            helperText: 'Opcional. Permite ver tu progreso en la pantalla de historial.',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.isEmpty) return null; // Es opcional
            if ((double.tryParse(v) ?? 0) <= 0) return 'Si la estableces, debe ser un peso válido';
            return null;
          },
        ),
      ],
    );
  }
}
