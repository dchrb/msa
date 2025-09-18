import 'package:flutter/material.dart';
import 'package:msa/providers/meta1_provider.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/theme_provider.dart';

class MetaConfig extends StatefulWidget {
  const MetaConfig({super.key});

  @override
  State<MetaConfig> createState() => _MetaConfigState();
}

class _MetaConfigState extends State<MetaConfig> {
  final _deficitController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final metaProvider = context.read<Meta1Provider>();
      _deficitController.text = metaProvider.deficit.toString();
      _isEditing = metaProvider.caloriasBase <= 0;
    });
  }

  @override
  void dispose() {
    _deficitController.dispose();
    super.dispose();
  }

  void _guardarMeta(double caloriasBase) {
    final metaProvider = context.read<Meta1Provider>();
    final deficit = int.tryParse(_deficitController.text) ?? 500;
    
    int metaBaseFinal = caloriasBase.toInt() > 1000 ? caloriasBase.toInt() : 1000;

    metaProvider.setCaloriasBase(metaBaseFinal);
    metaProvider.setDeficit(deficit);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meta calórica actualizada")),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final metaProvider = context.watch<Meta1Provider>();
    final profileProvider = context.watch<ProfileProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    if (profileProvider.isLoading || metaProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: themeProvider.primaryColor),
      );
    }
    
    final caloriasRecomendadas = profileProvider.caloriasRecomendadas;
    final metaFinal = metaProvider.metaCalorias;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Barra personalizada SIN botón de retroceso
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: themeProvider.primaryColor,
            border: Border(
              bottom: BorderSide(color: Colors.black.withOpacity(0.3), width: 1),
            ),
          ),
          child: const Text(
            "Meta Calórica",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 🔹 Contenido scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing || metaFinal <= 0) ...[
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.recommend, color: Colors.blue),
                      title: const Text("Calorías de Mantenimiento Sugeridas"),
                      subtitle: Text(
                        '${caloriasRecomendadas > 0 ? caloriasRecomendadas.toStringAsFixed(0) : 'N/A'} kcal/día',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      isThreeLine: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Tu Déficit/Superávit Calórico:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _deficitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Ej: 500 para déficit, -300 para superávit",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                      onPressed: () => _guardarMeta(caloriasRecomendadas),
                      icon: const Icon(Icons.save),
                      label: const Text("Guardar y Calcular Meta"),
                    ),
                  ),
                ] else ...[
                  Card(
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.flag, color: Colors.green),
                      title: const Text('Tu Meta Diaria Final es:'),
                      trailing: Text(
                        "${metaFinal} kcal",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Editar Meta Calórica"),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}