import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:msa/providers/profile_provider.dart';
import 'package:msa/models/profile.dart';
import 'package:msa/pantallas/pantalla_metas.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoController = TextEditingController();

  Sexo? _sexoSeleccionado;
  NivelActividad? _actividadSeleccionada;
  File? _imagenSeleccionada;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosDelPerfil();
    });
  }

  void _cargarDatosDelPerfil() {
    final profile = context.read<ProfileProvider>().profile;
    if (!mounted) return;
    setState(() {
      _nombreController.text = profile?.name ?? '';
      _edadController.text = profile?.age.toString() ?? '';
      _alturaController.text = profile?.height.toString() ?? '';
      _pesoController.text = profile?.currentWeight.toString() ?? '';
      _sexoSeleccionado = profile?.sex;
      _actividadSeleccionada = profile?.activityLevel;

      if (profile != null && profile.imagePath != null && profile.imagePath!.isNotEmpty) {
        _imagenSeleccionada = File(profile.imagePath!);
      } else {
        _imagenSeleccionada = null;
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (_formKey.currentState?.validate() ?? false) {
      final profileProvider = context.read<ProfileProvider>();
      
      await profileProvider.guardarPerfil(
        nombre: _nombreController.text,
        edad: int.tryParse(_edadController.text),
        altura: double.tryParse(_alturaController.text),
        peso: double.tryParse(_pesoController.text),
        sexo: _sexoSeleccionado,
        nivelActividad: _actividadSeleccionada,
        imagePath: _imagenSeleccionada?.path,
      );

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado con éxito"), backgroundColor: Colors.green)
        );
        setState(() { _isEditing = false; });
      }
    }
  }

  void _irAPantallaMetas() {
     Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PantallaMetas())).then((_) {
      _cargarDatosDelPerfil();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileImage(),
            const SizedBox(height: 24),
            _isEditing ? _buildEditCard() : _buildViewMode(context, profile),
            const SizedBox(height: 24),
            _buildGuestUpgradeSection(context), 
            _buildBackupSection(context), 
            const SizedBox(height: 24),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode(BuildContext context, Profile? profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildViewCard(profile),
        const SizedBox(height: 24),
        _buildGoalsCard(context, profile),
      ],
    );
  }
  
  Widget _buildViewCard(Profile? profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             _buildViewTile(Icons.person_outline, "Nombre", profile?.name),
             _buildViewTile(Icons.cake_outlined, "Edad", profile?.age.toString()),
             _buildViewTile(Icons.height_outlined, "Altura", "${profile?.height.toStringAsFixed(1) ?? 'N/A'} cm"),
             _buildViewTile(Icons.monitor_weight_outlined, "Peso Actual", "${profile?.currentWeight.toStringAsFixed(1) ?? 'N/A'} kg"),
             _buildViewTile(Icons.wc_outlined, "Sexo", profile?.sex.toString().split('.').last),
             _buildViewTile(Icons.directions_run_outlined, "Nivel de Actividad", profile?.activityLevel.toString().split('.').last, showDivider: false),
          ],
        ),
      )
    );
  }

  Widget _buildGoalsCard(BuildContext context, Profile? profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: Colors.grey),
            title: const Text("Mis Metas", style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: TextButton(onPressed: _irAPantallaMetas, child: const Text("Editar")),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildViewTile(Icons.local_fire_department_outlined, "Meta de Calorías", "${profile?.calorieGoal.toStringAsFixed(0) ?? 'No est.'} kcal"),
          _buildViewTile(Icons.monitor_weight_outlined, "Meta de Peso", "${profile?.weightGoal?.toStringAsFixed(1) ?? 'No est.'} kg", showDivider: false),
        ],
      ),
    );
  }

  Widget _buildEditCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextFormField(controller: _edadController, decoration: const InputDecoration(labelText: 'Edad'), keyboardType: TextInputType.number),
              TextFormField(controller: _alturaController, decoration: const InputDecoration(labelText: 'Altura (cm)'), keyboardType: TextInputType.number),
              TextFormField(controller: _pesoController, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number),
              DropdownButtonFormField<Sexo>(
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: Sexo.values.map((Sexo sex) {
                  return DropdownMenuItem<Sexo>(value: sex, child: Text(sex.toString().split('.').last));
                }).toList(),
                onChanged: (Sexo? newValue) {
                  setState(() {
                    _sexoSeleccionado = newValue;
                  });
                },
                initialValue: _sexoSeleccionado,
              ),
              DropdownButtonFormField<NivelActividad>(
                decoration: const InputDecoration(labelText: 'Nivel de Actividad'),
                items: NivelActividad.values.map((NivelActividad level) {
                  return DropdownMenuItem<NivelActividad>(value: level, child: Text(level.toString().split('.').last));
                }).toList(),
                onChanged: (NivelActividad? newValue) {
                  setState(() {
                    _actividadSeleccionada = newValue;
                  });
                },
                initialValue: _actividadSeleccionada,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _guardarCambios, child: const Text('Guardar Cambios'))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() => const SizedBox.shrink();
  Widget _buildGuestUpgradeSection(BuildContext context) => const SizedBox.shrink();
  Widget _buildBackupSection(BuildContext context) => const SizedBox.shrink();
  Widget _buildLogoutButton(BuildContext context) => const SizedBox.shrink();
  Widget _buildViewTile(IconData icon, String title, String? subtitle, {bool showDivider = true}) => ListTile(title: Text(title), subtitle: Text(subtitle ?? 'N/A'));
}