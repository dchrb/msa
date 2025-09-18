// lib/pantallas/pantalla_onboarding.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msa/pantallas/pantalla_inicio.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PantallaOnboarding extends StatefulWidget {
  const PantallaOnboarding({super.key});

  @override
  State<PantallaOnboarding> createState() => _PantallaOnboardingState();
}

class _PantallaOnboardingState extends State<PantallaOnboarding> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoController = TextEditingController();
  
  Sexo? _sexoSeleccionado;
  NivelActividad? _actividadSeleccionada;
  File? _imagenSeleccionada;
  
  bool _mostrarFormulario = false;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final name = p.basename(pickedFile.path);
      final imageFile = File('${directory.path}/$name');
      final newImage = await File(pickedFile.path).copy(imageFile.path);

      setState(() {
        _imagenSeleccionada = newImage;
      });
    }
  }

  void _guardarYContinuar() {
    if (_formKey.currentState!.validate()) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.guardarPerfil(
        nombre: _nombreController.text,
        edad: int.parse(_edadController.text),
        altura: double.parse(_alturaController.text),
        peso: double.parse(_pesoController.text),
        sexo: _sexoSeleccionado!,
        nivelActividad: _actividadSeleccionada!,
        imagePath: _imagenSeleccionada?.path,
      ).then((_) {
        // La llamada a la insignia ya está aquí, lo cual es correcto
        context.read<InsigniaProvider>().verificarInsigniaDePerfil(context);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaInicio()));
      });
    }
  }
  
  void _continuarSinPerfil() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PantallaInicio()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _mostrarFormulario
                ? _buildFormularioPerfil()
                : _buildOpcionesIniciales(),
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionesIniciales() {
    return Column(
      key: const ValueKey('opciones'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.shield_outlined, color: Colors.teal, size: 60),
        const SizedBox(height: 16),
        const Text(
          '¡Bienvenido a Mi Salud Activa!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Para personalizar tu experiencia y ofrecerte cálculos precisos (como tu meta calórica y tu IMC), necesitas un perfil. Puedes crearlo ahora o más tarde.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _mostrarFormulario = true;
            });
          },
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('Registrar mi perfil'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _continuarSinPerfil,
          child: const Text('Continuar como invitado'), // 👈 Texto modificado aquí
        ),
      ],
    );
  }

  Widget _buildFormularioPerfil() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('formulario'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Crea tu perfil',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tu información se guarda de forma segura en tu dispositivo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Divider(height: 40),
          Center(
            child: GestureDetector(
              onTap: _seleccionarImagen,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _imagenSeleccionada != null
                    ? FileImage(_imagenSeleccionada!)
                    : null,
                child: _imagenSeleccionada == null
                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _edadController, decoration: const InputDecoration(labelText: 'Edad'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _alturaController, decoration: const InputDecoration(labelText: 'Altura (cm)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _pesoController, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 16),
          DropdownButtonFormField<Sexo>(value: _sexoSeleccionado, hint: const Text("Sexo"), items: Sexo.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(), onChanged: (v) => setState(() => _sexoSeleccionado = v), validator: (v) => v == null ? 'Requerido' : null),
          const SizedBox(height: 16),
          DropdownButtonFormField<NivelActividad>(value: _actividadSeleccionada, hint: const Text("Nivel de Actividad"), items: NivelActividad.values.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(), onChanged: (v) => setState(() => _actividadSeleccionada = v), validator: (v) => v == null ? 'Requerido' : null),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _guardarYContinuar,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Guardar y Comenzar'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _mostrarFormulario = false;
              });
            },
            child: const Text('Cancelar y volver'),
          ),
        ],
      ),
    );
  }
}