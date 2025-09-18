// lib/pantallas/pantalla_perfil.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:msa/providers/insignia_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    _nombreController.text = profile.nombre ?? '';
    _edadController.text = profile.edad?.toString() ?? '';
    _alturaController.text = profile.altura?.toString() ?? '';
    _pesoController.text = profile.peso?.toString() ?? '';
    _sexoSeleccionado = profile.sexo;
    _actividadSeleccionada = profile.nivelActividad;

    if (profile.imagePath != null) {
      _imagenSeleccionada = File(profile.imagePath!);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      // --- CAMBIO 2: Usamos el apodo 'p' para llamar a la función ---
      final name = p.basename(pickedFile.path);
      final imageFile = File('${directory.path}/$name');
      final newImage = await File(pickedFile.path).copy(imageFile.path);
      setState(() {
        _imagenSeleccionada = newImage;
      });
    }
  }

  void _guardarCambios() {
    if (_formKey.currentState!.validate()) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.guardarPerfil(
        nombre: _nombreController.text,
        edad: int.parse(_edadController.text),
        altura: double.parse(_alturaController.text),
        peso: double.parse(_pesoController.text),
        sexo: _sexoSeleccionado!,
        nivelActividad: _actividadSeleccionada!,
        imagePath: _imagenSeleccionada?.path ?? profileProvider.imagePath,
      ).then((_) {
        // Llama a la insignia al guardar el perfil
        context.read<InsigniaProvider>().verificarInsigniaDePerfil(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado"))
        );
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _guardarCambios)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _seleccionarImagen,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _imagenSeleccionada != null ? FileImage(_imagenSeleccionada!) : null,
                    child: _imagenSeleccionada == null ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey) : null,
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
            ],
          ),
        ),
      ),
    );
  }
}