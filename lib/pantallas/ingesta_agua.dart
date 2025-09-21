import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/water_provider.dart';
import 'package:intl/intl.dart';
import 'package:msa/models/agua.dart';
import 'package:msa/providers/racha_provider.dart';
import 'package:msa/providers/insignia_provider.dart';

class IngestaAgua extends StatefulWidget {
  const IngestaAgua({super.key});

  @override
  State<IngestaAgua> createState() => _IngestaAguaState();
}

class _IngestaAguaState extends State<IngestaAgua> with TickerProviderStateMixin {
  DateTime _fechaSeleccionada = DateTime.now();
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

    void _onSave(BuildContext context, double cantidad) async {
    final waterProvider = context.read<WaterProvider>();
    final rachaProvider = context.read<RachaProvider>();
    final insigniaProvider = context.read<InsigniaProvider>();

    await waterProvider.addAgua(cantidad, _fechaSeleccionada);

    if (DateUtils.isSameDay(_fechaSeleccionada, DateTime.now())) {
      // Otorga la insignia por el primer vaso. `otorgarInsignia` previene duplicados.
      insigniaProvider.otorgarInsignia('ag_ins_primer_vaso');

      // El provider `waterProvider` refactorizado tiene un getter para esto.
      final bool metaCumplida = waterProvider.consumoTotalHoy >= waterProvider.metaDiaria;

      // Racha: Días seguidos cumpliendo la meta
      rachaProvider.actualizarRacha('ag_racha_meta_agua', metaCumplida);

      // Insignia: Primera vez que se cumple la meta
      if (metaCumplida) {
        insigniaProvider.otorgarInsignia('ag_ins_meta_diaria');
      }
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Agua registrada!'), backgroundColor: Colors.green),
    );
  }


  void _showAddOrEditDialog(BuildContext context, {Agua? registro}) {
    final bool isEditing = registro != null;
    final controller = TextEditingController(
      text: isEditing ? registro.amount.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? 'Editar Registro' : 'Añadir Cantidad'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Cantidad en ml',
            hintText: 'Ej: 250',
            icon: Icon(Icons.local_drink_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final double? val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                if (isEditing) {
                  context.read<WaterProvider>().updateAgua(registro, val);
                } else {
                  _onSave(context, val);
                }
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showSetGoalDialog(BuildContext context) {
    final provider = context.read<WaterProvider>();
    final controller = TextEditingController(text: provider.metaDiaria.toStringAsFixed(0));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Establecer Meta Diaria'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Ej: 2500'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final double? val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                provider.setMeta(val);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final waterProvider = context.watch<WaterProvider>();
    final registrosDelDia = waterProvider.getRegistrosPorFecha(_fechaSeleccionada);
    final ingestaParaLaFecha = registrosDelDia.fold<double>(0, (sum, item) => sum + item.amount);
    final double porcentaje = (ingestaParaLaFecha / (waterProvider.metaDiaria > 0 ? waterProvider.metaDiaria : 2500)).clamp(0.0, 1.0);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAquariumProgressCard(context, porcentaje, ingestaParaLaFecha, waterProvider.metaDiaria),
            const SizedBox(height: 20),
            _buildDatePickerSection(context, _fechaSeleccionada),
            const SizedBox(height: 20),
            _buildHistoryList(context, registrosDelDia),
          ],
        ),
      ),
    );
  }

  Widget _buildAquariumProgressCard(BuildContext context, double porcentaje, double ingesta, double meta) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: Stack(
              children: [
                Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.lightBlue.shade100, Colors.yellow.shade100]))),
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) => ClipPath(
                    clipper: _WaveClipper(_waveController.value, porcentaje),
                    child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.blue.shade700, Colors.blue.shade400]))),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${ingesta.toStringAsFixed(0)} ml', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black.withAlpha(128), blurRadius: 4, offset: const Offset(1, 1))])),
                      GestureDetector(
                        onTap: () => _showSetGoalDialog(context),
                        child: Text('Meta: ${meta.toStringAsFixed(0)} ml', style: TextStyle(fontSize: 16, color: Colors.white.withAlpha(230), shadows: [Shadow(color: Colors.black.withAlpha(128), blurRadius: 2)]))
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAddWaterButton(250, () => _onSave(context, 250)),
                const SizedBox(width: 16),
                _buildAddWaterButton(500, () => _onSave(context, 500)),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showAddOrEditDialog(context),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddWaterButton(double amount, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('${amount.toInt()} ml', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDatePickerSection(BuildContext context, DateTime fecha) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => setState(() => _fechaSeleccionada = _fechaSeleccionada.subtract(const Duration(days: 1)))),
            TextButton(
              onPressed: () => _seleccionarFecha(context),
              child: Text(DateFormat('EEEE, d MMMM', 'es_ES').format(fecha), style: const TextStyle(fontSize: 16)),
            ),
            IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () {
              if (DateUtils.isSameDay(_fechaSeleccionada, DateTime.now())) return;
              setState(() => _fechaSeleccionada = _fechaSeleccionada.add(const Duration(days: 1)));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<Agua> registros) {
    if (registros.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32.0), child: Text('No hay registros de agua para esta fecha.', style: TextStyle(fontSize: 16, color: Colors.grey))));
    }

    registros.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: registros.length,
      itemBuilder: (context, index) {
        final registro = registros[index];
        return Card(
          key: ValueKey(registro.id),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(Icons.local_drink_outlined, color: Colors.blue, size: 30),
            title: Text('${registro.amount.toStringAsFixed(0)} ml', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat('HH:mm a', 'es_ES').format(registro.timestamp)),
            onTap: () => _showAddOrEditDialog(context, registro: registro),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                context.read<WaterProvider>().eliminarRegistro(registro.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro de agua eliminado.'), backgroundColor: Colors.redAccent));
              },
            ),
          ),
        );
      },
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double animationValue;
  final double waterLevelPercent;
  _WaveClipper(this.animationValue, this.waterLevelPercent);

  @override
  Path getClip(Size size) {
    Path path = Path();
    double waveOffsetX = size.width * (1 - animationValue);
    double waterHeight = size.height * (1 - waterLevelPercent);
    path.moveTo(0 - waveOffsetX, waterHeight);
    for (double i = 0; i < size.width * 2; i += size.width) {
      path.quadraticBezierTo(i + size.width / 4 - waveOffsetX, waterHeight - 15, i + size.width / 2 - waveOffsetX, waterHeight);
      path.quadraticBezierTo(i + size.width * 3/4 - waveOffsetX, waterHeight + 15, i + size.width - waveOffsetX, waterHeight);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
