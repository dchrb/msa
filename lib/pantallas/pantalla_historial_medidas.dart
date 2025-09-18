// lib/pantallas/pantalla_historial_medidas.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:msa/models/medida.dart'; 
import 'package:msa/providers/medida_provider.dart'; 
import 'package:msa/providers/profile_provider.dart';
import 'package:msa/pantallas/pantalla_registro_medidas.dart';
import 'package:tuple/tuple.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:msa/providers/insignia_provider.dart';

class PantallaHistorialMedidas extends StatefulWidget {
  const PantallaHistorialMedidas({super.key});

  @override
  State<PantallaHistorialMedidas> createState() => _PantallaHistorialMedidasState();
}

class _PantallaHistorialMedidasState extends State<PantallaHistorialMedidas> {
  String _graficoSeleccionado = 'peso';
  DateTime? _fechaFiltrada;

  Future<void> _seleccionarFechaFiltro() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _fechaFiltrada ?? DateTime.now(), firstDate: DateTime(2023), lastDate: DateTime.now(), locale: const Locale('es', 'ES'));
    if (picked != null) { setState(() { _fechaFiltrada = picked; }); }
  }

  Tuple2<String, Color> _getIMCCategory(double imc) {
    if (imc < 18.5) return const Tuple2('Bajo peso', Colors.blue);
    if (imc < 25) return const Tuple2('Peso normal', Colors.green);
    if (imc < 30) return const Tuple2('Sobrepeso', Colors.orange);
    return const Tuple2('Obesidad', Colors.red);
  }
  
  void _mostrarExplicacionIMC(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Qué es el IMC?"),
        content: const Text(
          "El Índice de Masa Corporal (IMC) es una medida que relaciona tu peso con tu altura para dar una estimación rápida de si tu peso es saludable.\n\nEs una guía orientativa, ya que no distingue entre masa muscular y grasa corporal.",
        ),
        actions: [
          TextButton(
            child: const Text("Entendido"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medidaProvider = context.watch<MedidaProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileSummary(profileProvider),
          const SizedBox(height: 16),
          _buildCurrentIMCSummary(context, profileProvider, medidaProvider), 
          const SizedBox(height: 30),
          if (medidaProvider.registros.isNotEmpty) ...[
            _buildChartSection(medidaProvider.registros),
            const SizedBox(height: 30),
            _buildHistoryList(medidaProvider.registros, medidaProvider),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Text(
                  'Aún no tienes registros.\nVe a la pestaña "Registrar" para añadir uno.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(ProfileProvider profileProvider) {
    if (!profileProvider.perfilCreado) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.blue),
          title: const Text("Crea tu perfil para empezar"),
          subtitle: const Text("Ve a 'Editar Perfil' en el menú lateral para añadir tus datos como la altura."),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const Divider(height: 20),
            Text('Nombre: ${profileProvider.nombre ?? 'N/A'}'),
            Text('Altura: ${profileProvider.altura?.toStringAsFixed(0) ?? 'N/A'} cm'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentIMCSummary(BuildContext context, ProfileProvider profileProvider, MedidaProvider medidaProvider) {
    if (profileProvider.isLoading || profileProvider.peso == null || profileProvider.altura == null || profileProvider.altura == 0) {
      return const SizedBox.shrink();
    }

    final double peso = profileProvider.peso!;
    final double alturaEnMetros = profileProvider.altura! / 100;
    final double imc = peso / (alturaEnMetros * alturaEnMetros);
    final categoria = _getIMCCategory(imc);

    const double minIMC = 15.0;
    const double maxIMC = 40.0;
    final double imcNormalizado = ((imc - minIMC) / (maxIMC - minIMC)).clamp(0.0, 1.0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Índice de Masa Corporal (IMC)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.grey),
                  onPressed: () => _mostrarExplicacionIMC(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              percent: imcNormalizado,
              lineHeight: 20.0,
              barRadius: const Radius.circular(10),
              center: Text(
                "Tu IMC: ${imc.toStringAsFixed(1)}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              progressColor: categoria.item2,
              backgroundColor: Colors.grey.shade300,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bajo', style: TextStyle(color: Colors.blue)),
                Text('Normal', style: TextStyle(color: Colors.green)),
                Text('Alto', style: TextStyle(color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Chip(
                label: Text(categoria.item1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: categoria.item2,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            if (medidaProvider.metaPeso != null) ...[
              const Divider(height: 30),
              _buildMetaPesoSummary(peso, medidaProvider.metaPeso!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetaPesoSummary(double pesoActual, double metaPeso) {
    final double diferencia = pesoActual - metaPeso;
    final bool objetivoCumplido = diferencia <= 0;
    final String mensaje = objetivoCumplido
        ? '¡Objetivo de peso cumplido!'
        : 'Te faltan ${diferencia.toStringAsFixed(1)} kg para tu meta.';

    return Row(
      children: [
        Icon(
          objetivoCumplido ? Icons.check_circle : Icons.flag_circle,
          color: objetivoCumplido ? Colors.green : Colors.blue,
          size: 30,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            mensaje,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }


  Widget _buildChartSection(List<Medida> registros) {
    if (registros.length < 2) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text('Necesitas al menos 2 registros para ver el gráfico.')));
    }
    List<Medida> registrosOrdenados = List.from(registros)..sort((a, b) => a.fecha.compareTo(b.fecha));

    final spots = registrosOrdenados.map((medida) {
      double? valor = _getMetricaValue(medida, _graficoSeleccionado);
      if (valor == null) return null;
      return FlSpot(medida.fecha.millisecondsSinceEpoch.toDouble(), valor);
    }).whereType<FlSpot>().toList();

    if (spots.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 20.0), child: Text('No hay datos para la métrica "$_graficoSeleccionado".')));
    }

    final double minX = spots.first.x;
    final double maxX = spots.last.x;
    final double range = maxX - minX;
    final double interval = range > 0 ? range / 5 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Progreso de Medidas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: _graficoSeleccionado, isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'peso', child: Text('Peso')), DropdownMenuItem(value: 'pecho', child: Text('Pecho')), DropdownMenuItem(value: 'brazo', child: Text('Brazo')),
            DropdownMenuItem(value: 'cintura', child: Text('Cintura')), DropdownMenuItem(value: 'caderas', child: Text('Caderas')), DropdownMenuItem(value: 'muslo', child: Text('Muslo')),
          ],
          onChanged: (newValue) => setState(() => _graficoSeleccionado = newValue!),
        ),
        const SizedBox(height: 20),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => Colors.blueGrey.withOpacity(0.8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final fecha = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)}\n', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        children: [ TextSpan(text: DateFormat('dd MMM yyyy', 'es_ES').format(fecha), style: const TextStyle(color: Colors.white70)) ],
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                      final fecha = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      final text = Text(DateFormat('dd/MM').format(fecha), style: const TextStyle(fontSize: 10));
                      return SideTitleWidget(axisSide: meta.axisSide, child: text);
                    }, reservedSize: 30, interval: interval)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots, isCurved: true, color: Theme.of(context).primaryColor, barWidth: 3, dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double? _getMetricaValue(Medida medida, String metrica) {
    switch (metrica) {
      case 'peso': return medida.peso; case 'pecho': return medida.pecho; case 'brazo': return medida.brazo;
      case 'cintura': return medida.cintura; case 'caderas': return medida.caderas; case 'muslo': return medida.muslo;
      default: return null;
    }
  }

  Widget _buildHistoryList(List<Medida> todosLosRegistros, MedidaProvider medidaProvider) {
    final registrosFiltrados = _fechaFiltrada == null ? todosLosRegistros : todosLosRegistros.where((r) => DateUtils.isSameDay(r.fecha, _fechaFiltrada)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Historial de Registros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.calendar_today), onPressed: _seleccionarFechaFiltro),
          ],
        ),
        if (_fechaFiltrada != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Chip(
              label: Text('Mostrando: ${DateFormat('dd/MM/yyyy', 'es_ES').format(_fechaFiltrada!)}'),
              onDeleted: () => setState(() => _fechaFiltrada = null),
            ),
          ),
        const SizedBox(height: 10),
        if (registrosFiltrados.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text('No hay registros para la fecha seleccionada.')))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: registrosFiltrados.length,
            itemBuilder: (context, index) {
              final medida = registrosFiltrados[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(DateFormat('dd/MM/yyyy - hh:mm a', 'es_ES').format(medida.fecha)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Peso: ${medida.peso.toStringAsFixed(1)} kg'),
                      if (medida.pecho != null) Text('Pecho: ${medida.pecho!.toStringAsFixed(1)} cm'),
                      if (medida.brazo != null) Text('Brazo: ${medida.brazo!.toStringAsFixed(1)} cm'),
                      if (medida.cintura != null) Text('Cintura: ${medida.cintura!.toStringAsFixed(1)} cm'),
                      if (medida.caderas != null) Text('Caderas: ${medida.caderas!.toStringAsFixed(1)} cm'),
                      if (medida.muslo != null) Text('Muslo: ${medida.muslo!.toStringAsFixed(1)} cm'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(medida)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                          showDialog(context: context, builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar Registro'),
                                content: const Text('¿Estás seguro de que quieres eliminar este registro?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
                                  TextButton(
                                    onPressed: () {
                                      medidaProvider.eliminarMedida(medida.id);
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showEditDialog(Medida medida) {
    final editPesoController = TextEditingController(text: medida.peso.toString());
    final editPechoController = TextEditingController(text: medida.pecho?.toString() ?? '');
    final editBrazoController = TextEditingController(text: medida.brazo?.toString() ?? '');
    final editCinturaController = TextEditingController(text: medida.cintura?.toString() ?? '');
    final editCaderasController = TextEditingController(text: medida.caderas?.toString() ?? '');
    final editMusloController = TextEditingController(text: medida.muslo?.toString() ?? '');

    showDialog(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Editar Medida'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: editPesoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Peso (kg)')),
              TextField(controller: editPechoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pecho (cm)')),
              TextField(controller: editBrazoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Brazo (cm)')),
              TextField(controller: editCinturaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cintura (cm)')),
              TextField(controller: editCaderasController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Caderas (cm)')),
              TextField(controller: editMusloController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Muslo (cm)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final newPeso = double.tryParse(editPesoController.text);
              if (newPeso != null && newPeso > 0) {
                Provider.of<MedidaProvider>(context, listen: false).editarMedida(
                  medida.id, peso: newPeso, altura: medida.altura,
                  pecho: double.tryParse(editPechoController.text), brazo: double.tryParse(editBrazoController.text),
                  cintura: double.tryParse(editCinturaController.text), caderas: double.tryParse(editCaderasController.text),
                  muslo: double.tryParse(editMusloController.text),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}