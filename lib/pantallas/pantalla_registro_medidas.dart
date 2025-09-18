import 'package:flutter/material.dart';
import 'package:msa/providers/medida_provider.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:msa/providers/meta_provider.dart';
import 'package:msa/providers/water_provider.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/entrenamiento_provider.dart';

class PantallaRegistroMedidas extends StatefulWidget {
  const PantallaRegistroMedidas({super.key});

  @override
  State<PantallaRegistroMedidas> createState() => _PantallaRegistroMedidasState();
}

class _PantallaRegistroMedidasState extends State<PantallaRegistroMedidas> {
  final _pesoController = TextEditingController();
  final _pechoController = TextEditingController();
  final _brazoController = TextEditingController();
  final _cinturaController = TextEditingController();
  final _caderasController = TextEditingController();
  final _musloController = TextEditingController();
  final _metaPesoController = TextEditingController();

  bool _metaGuardada = false;

  @override
  void initState() {
    super.initState();
    final medidaProvider = context.read<MedidaProvider>();
    _metaPesoController.text = medidaProvider.metaPeso?.toString() ?? '';
    _metaGuardada = medidaProvider.metaPeso != null;
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _pechoController.dispose();
    _brazoController.dispose();
    _cinturaController.dispose();
    _caderasController.dispose();
    _musloController.dispose();
    _metaPesoController.dispose();
    super.dispose();
  }

  void _agregarRegistro() {
    final medidaProvider = context.read<MedidaProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final altura = profileProvider.altura;
    final peso = double.tryParse(_pesoController.text);

    if (peso != null && altura != null && peso > 0 && altura > 0) {
      medidaProvider.agregarMedida(
        peso: peso,
        altura: altura,
        pecho: double.tryParse(_pechoController.text),
        brazo: double.tryParse(_brazoController.text),
        cintura: double.tryParse(_cinturaController.text),
        caderas: double.tryParse(_caderasController.text),
        muslo: double.tryParse(_musloController.text),
      );
      profileProvider.actualizarPeso(peso);

      final insigniaProvider = context.read<InsigniaProvider>();
      insigniaProvider.verificarInsigniasDeMedidas(context, medidaProvider);

      final metaProvider = context.read<MetaProvider>();
      metaProvider.actualizarRachaMedidas();

      if (medidaProvider.metaPeso != null && peso <= medidaProvider.metaPeso!) {
        insigniaProvider.otorgarInsignia('peso_meta_1', context);
      }

      context.read<InsigniaProvider>().verificarHabitoTrio(
        context,
        context.read<WaterProvider>(),
        context.read<FoodProvider>(),
        context.read<EntrenamientoProvider>(),
      );


      _pesoController.clear();_pechoController.clear();_brazoController.clear();
      _cinturaController.clear();_caderasController.clear();_musloController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro de medida guardado.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un peso válido y asegúrate de tener tu altura guardada en el perfil.')));
    }
  }

  void _guardarMetaPeso() {
    final medidaProvider = context.read<MedidaProvider>();
    final peso = double.tryParse(_metaPesoController.text);
    if (peso != null && peso > 0) {
      medidaProvider.setMetaPeso(peso);
      setState(() {
        _metaGuardada = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meta de peso guardada.')));
    } else {
      medidaProvider.setMetaPeso(null);
      setState(() {
        _metaGuardada = false;
        _metaPesoController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meta de peso eliminada.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMetaPesoSection(),
          const Divider(height: 40),
          const Text(
            'Registra tu peso actual. Las demás medidas son opcionales.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(controller: _pesoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _pechoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pecho (cm)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _brazoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Brazo (cm)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _cinturaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cintura (cm)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _caderasController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Caderas (cm)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _musloController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Muslo (cm)', border: OutlineInputBorder())),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Guardar Medidas'),
            onPressed: _agregarRegistro,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPesoSection() {
    return Consumer<MedidaProvider>(
      builder: (context, medidaProvider, child) {
        if (medidaProvider.metaPeso != null && _metaGuardada) {
          return Card(
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.flag, color: Colors.blue),
              title: const Text('Tu meta de peso es:'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${medidaProvider.metaPeso!.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      setState(() {
                        _metaGuardada = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Meta de Peso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _metaPesoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Peso Objetivo (kg)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _metaPesoController.clear();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.flag),
                label: const Text('Establecer Meta de Peso'),
                onPressed: _guardarMetaPeso,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}