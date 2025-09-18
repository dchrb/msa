// lib/pantallas/ingesta_agua.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/water_provider.dart';
import 'package:msa/providers/insignia_provider.dart';
import 'package:msa/providers/meta_provider.dart';
import 'package:intl/intl.dart';
import 'package:msa/models/agua.dart';
import 'dart:math' as math;

class _AquariumObject {
  final Widget child;
  final double showAtPercent;
  final double left;
  final double top;
  final int durationInMs;
  final double offsetY;

  _AquariumObject({
    required this.child,
    required this.showAtPercent,
    required this.left,
    required this.top,
    required this.durationInMs,
    this.offsetY = 0.1,
  });
}

class IngestaAgua extends StatefulWidget {
  const IngestaAgua({super.key});

  @override
  State<IngestaAgua> createState() => _IngestaAguaState();
}

class _IngestaAguaState extends State<IngestaAgua> with TickerProviderStateMixin {
  DateTime _fechaSeleccionada = DateTime.now();
  late AnimationController _waveController;
  List<_AquariumObject>? _aquariumObjects;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    // Se llama a la función aquí para que se genere una sola vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateAquariumObjects(MediaQuery.of(context).size.width);
      if (mounted) setState(() {});
    });
  }

  // =================== AQUARIUM OBJECTS ===================
  void _generateAquariumObjects(double maxWidth) {
    _aquariumObjects = [];
    final random = math.Random();
    final fishColors = [
      Colors.orange,
      Colors.redAccent,
      Colors.yellow.shade600,
      Colors.purpleAccent,
      Colors.pink.shade300,
      Colors.cyan,
      Colors.greenAccent,
    ];

    final double aquariumWidth = maxWidth - 40;

    // 10 peces de colores
    for (int i = 0; i < 10; i++) {
      final fishColor = fishColors[random.nextInt(fishColors.length)];
      _aquariumObjects!.add(
        _AquariumObject(
          showAtPercent: 0.1 + random.nextDouble() * 0.8,
          left: random.nextDouble() * aquariumWidth,
          top: 50 + random.nextDouble() * 150,
          durationInMs: 2000 + random.nextInt(2000),
          offsetY: 0.05 + random.nextDouble() * 0.1,
          child: Text(
            '🐠',
            style: TextStyle(
              fontSize: 20 + random.nextDouble() * 12,
              color: fishColor,
              shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 3)],
            ),
          ),
        ),
      );
    }

    // Delfín 🐬
    _aquariumObjects!.add(
      _AquariumObject(
        showAtPercent: 0.4,
        left: random.nextDouble() * aquariumWidth,
        top: 80 + random.nextDouble() * 100,
        durationInMs: 4000,
        offsetY: 0.15,
        child: const Text('🐬', style: TextStyle(fontSize: 45)),
      ),
    );

    // Tortuga 🐢
    _aquariumObjects!.add(
      _AquariumObject(
        showAtPercent: 0.3,
        left: random.nextDouble() * (aquariumWidth * 0.5),
        top: 200,
        durationInMs: 4000,
        offsetY: 0.05,
        child: const Text('🐢', style: TextStyle(fontSize: 35)),
      ),
    );

    // Medusa 🪼
    _aquariumObjects!.add(
      _AquariumObject(
        showAtPercent: 0.65,
        left: random.nextDouble() * aquariumWidth,
        top: 50,
        durationInMs: 2500,
        offsetY: 0.15,
        child: const Text('🪼', style: TextStyle(fontSize: 40)),
      ),
    );

    // Estrella de mar 🌟
    _aquariumObjects!.add(
      _AquariumObject(
        showAtPercent: 0.6,
        left: random.nextDouble() * aquariumWidth,
        top: 200 + random.nextDouble() * 40,
        durationInMs: 3500,
        offsetY: 0.07,
        child: const Text('🌟', style: TextStyle(fontSize: 35)),
      ),
    );

    // 20 Burbujas 🫧
    for (int i = 0; i < 20; i++) {
      _aquariumObjects!.add(
        _AquariumObject(
          showAtPercent: 0.05 + random.nextDouble() * 0.8,
          left: random.nextDouble() * aquariumWidth,
          top: 120 + random.nextDouble() * 80,
          durationInMs: 1500 + random.nextInt(1000),
          offsetY: 0.2 + random.nextDouble() * 0.3,
          child: Text(
            '🫧',
            style: TextStyle(fontSize: 10 + random.nextDouble() * 15),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  // =================== FECHA ===================
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  // =================== BUILD ===================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<WaterProvider, InsigniaProvider, MetaProvider>(
        builder: (context, waterProvider, insigniaProvider, metaProvider, child) {
          final ingestaParaLaFecha = waterProvider.getIngestaPorFecha(_fechaSeleccionada);
          double porcentaje = (ingestaParaLaFecha / (waterProvider.meta > 0 ? waterProvider.meta : 2500)).clamp(0.0, 1.0);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildAquariumProgressCard(context, porcentaje, ingestaParaLaFecha, waterProvider, insigniaProvider, metaProvider),
                  const SizedBox(height: 20),
                  _buildDatePickerSection(context, _fechaSeleccionada),
                  const SizedBox(height: 20),
                  _buildHistoryList(context, waterProvider.getRegistrosPorFecha(_fechaSeleccionada)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =================== AQUARIUM CARD, BOTONES Y DIALOGOS ===================
  Widget _buildAquariumProgressCard(BuildContext context, double porcentaje, double ingesta, WaterProvider waterProvider, InsigniaProvider insigniaProvider, MetaProvider metaProvider) {
    void registrarYVerificar(double cantidad) {
      final ingestaAntesDeAnadir = waterProvider.getIngestaPorFecha(_fechaSeleccionada);
      waterProvider.addAgua(cantidad, _fechaSeleccionada);

      final fechaActual = DateTime.now();
      if (DateUtils.isSameDay(_fechaSeleccionada, fechaActual)) {
        insigniaProvider.verificarInsigniasDeAgua(context, waterProvider, _fechaSeleccionada);

        final ingestaDespuesDeAnadir = waterProvider.getIngestaPorFecha(_fechaSeleccionada);
        if (ingestaAntesDeAnadir < waterProvider.meta && ingestaDespuesDeAnadir >= waterProvider.meta) {
          metaProvider.actualizarRachaAgua();
        }
      }
    }

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
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.lightBlue.shade100, Colors.yellow.shade100],
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return ClipPath(
                      clipper: _WaveClipper(_waveController.value, porcentaje),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.blue.shade700, Colors.blue.shade400],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (_aquariumObjects != null)
                  ..._aquariumObjects!.map((obj) {
                    return _FloatingAnimation(
                      show: porcentaje >= obj.showAtPercent,
                      left: obj.left,
                      top: obj.top,
                      durationInMs: obj.durationInMs,
                      offsetY: obj.offsetY,
                      child: obj.child,
                    );
                  }),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${ingesta.toStringAsFixed(0)} ml',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(1,1))],
                        ),
                      ),
                      Text(
                        'Meta: ${waterProvider.meta.toStringAsFixed(0)} ml',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAddWaterButton(250, registrarYVerificar),
                    const SizedBox(width: 16),
                    _buildAddWaterButton(500, registrarYVerificar),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _showSetGoalDialog(context, waterProvider),
                  icon: Icon(Icons.edit, size: 16, color: Colors.grey.shade700),
                  label: Text(
                    'Editar meta diaria',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddWaterButton(double amount, void Function(double) onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.local_drink, color: Colors.white),
        label: Text(
          '+${amount.toInt()} ml',
          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => onPressed(amount),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
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
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                setState(() { _fechaSeleccionada = _fechaSeleccionada.subtract(const Duration(days: 1)); });
              },
            ),
            TextButton(
              onPressed: () => _seleccionarFecha(context),
              child: Text(DateFormat('EEEE, d MMMM', 'es_ES').format(fecha), style: const TextStyle(fontSize: 16)),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                if (DateUtils.isSameDay(_fechaSeleccionada, DateTime.now())) return;
                setState(() { _fechaSeleccionada = _fechaSeleccionada.add(const Duration(days: 1)); });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<Agua> registros) {
    if (registros.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text('No hay registros de agua para esta fecha.'),
      );
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: registros.length,
      itemBuilder: (context, index) {
        final registro = registros[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Icon(Icons.water_drop, color: Theme.of(context).primaryColor, size: 30),
            title: Text('${registro.amount.toStringAsFixed(0)} ml'),
            subtitle: Text(DateFormat('HH:mm').format(registro.timestamp)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(context, registro),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Provider.of<WaterProvider>(context, listen: false).eliminarRegistro(registro.id);
                    // --- FEEDBACK AÑADIDO: Mostrar un SnackBar al eliminar ---
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registro de agua eliminado.')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSetGoalDialog(BuildContext context, WaterProvider provider) {
    final TextEditingController controller = TextEditingController(text: provider.meta.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Establecer meta diaria'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Ej: 2500'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final double? nuevaMeta = double.tryParse(controller.text);
                if (nuevaMeta != null && nuevaMeta > 0) {
                  provider.setMeta(nuevaMeta);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Agua registro) {
    final TextEditingController controller = TextEditingController(text: registro.amount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar registro de agua'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Nueva cantidad en ml'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final double? nuevaCantidad = double.tryParse(controller.text);
                if (nuevaCantidad != null && nuevaCantidad > 0) {
                  Provider.of<WaterProvider>(context, listen: false).editarRegistro(registro.id, nuevaCantidad);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

// =================== FLOATING ANIMATION ===================
class _FloatingAnimation extends StatefulWidget {
  final Widget child;
  final bool show;
  final double? left;
  final double? top;
  final int durationInMs;
  final double offsetY;

  const _FloatingAnimation({
    required this.child,
    required this.show,
    this.left,
    this.top,
    this.durationInMs = 2000,
    this.offsetY = 0.1,
  });

  @override
  State<_FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<_FloatingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.durationInMs),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween(begin: const Offset(0, 0), end: Offset(0, widget.offsetY)).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _FloatingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.durationInMs != widget.durationInMs || oldWidget.offsetY != widget.offsetY) {
      _controller.duration = Duration(milliseconds: widget.durationInMs);
      _animation = Tween(begin: const Offset(0, 0), end: Offset(0, widget.offsetY)).animate(_controller);
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: AnimatedOpacity(
        opacity: widget.show ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: SlideTransition(
          position: _animation,
          child: widget.child,
        ),
      ),
    );
  }
}

// =================== WAVE CLIPPER ===================
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