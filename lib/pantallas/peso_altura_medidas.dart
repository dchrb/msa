import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:msa/providers/medida_provider.dart';
import 'package:msa/providers/profile_provider.dart';
import 'package:msa/models/medida.dart';
import 'package:tuple/tuple.dart';

class PesoAlturaMedidas extends StatefulWidget {
  const PesoAlturaMedidas({super.key});

  @override
  State<PesoAlturaMedidas> createState() => _PesoAlturaMedidasState();
}

class _PesoAlturaMedidasState extends State<PesoAlturaMedidas> {
  final _pesoController = TextEditingController();
  final _pechoController = TextEditingController();
  final _brazoController = TextEditingController();
  final _cinturaController = TextEditingController();
  final _caderasController = TextEditingController();
  final _musloController = TextEditingController();

  String _graficoSeleccionado = 'peso';
  DateTime? _fechaFiltrada;

  @override
  void dispose() {
    _pesoController.dispose();
    _pechoController.dispose();
    _brazoController.dispose();
    _cinturaController.dispose();
    _caderasController.dispose();
    _musloController.dispose();
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
      _pesoController.clear();_pechoController.clear();_brazoController.clear();
      _cinturaController.clear();_caderasController.clear();_musloController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro de medida guardado.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un peso válido y guarda tu altura en el perfil.')));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final medidaProvider = context.watch<MedidaProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileSummary(profileProvider),
            _buildCurrentIMCSummary(profileProvider),
            const SizedBox(height: 30),
            _buildMeasurementForm(),
            const SizedBox(height: 30),
            if (medidaProvider.registros.isNotEmpty) ...[
              _buildChartSection(medidaProvider.registros),
              const SizedBox(height: 30),
              _buildHistoryList(medidaProvider.registros, medidaProvider),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(child: Text('Aún no tienes registros en tu historial.')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummary(ProfileProvider profileProvider) {
    if (!profileProvider.perfilCreado) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text("Crea tu perfil para empezar"),
          subtitle: Text("Ve a 'Editar Perfil' en el menú lateral."),
        ),
      );
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mi Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Nombre: ${profileProvider.nombre ?? 'N/A'}'),
            Text('Altura: ${profileProvider.altura ?? 'N/A'} cm'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentIMCSummary(ProfileProvider profileProvider) {
    if (profileProvider.isLoading || profileProvider.peso == null || profileProvider.altura == null || profileProvider.altura == 0) {
      return const SizedBox.shrink();
    }

    final double peso = profileProvider.peso!;
    final double alturaEnMetros = profileProvider.altura! / 100;
    final double imc = peso / (alturaEnMetros * alturaEnMetros);
    final categoria = _getIMCCategory(imc);

    return Card(
      color: categoria.item2.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Tu Índice de Masa Corporal (IMC) Actual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(imc.toStringAsFixed(1), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: categoria.item2)),
                Chip(
                  label: Text(categoria.item1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: categoria.item2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Nuevo Registro de Medidas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextField(controller: _pesoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Peso (kg)')),
        TextField(controller: _pechoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pecho (cm)', hintText: 'Opcional')),
        TextField(controller: _brazoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Brazo (cm)', hintText: 'Opcional')),
        TextField(controller: _cinturaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cintura (cm)', hintText: 'Opcional')),
        TextField(controller: _caderasController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Caderas (cm)', hintText: 'Opcional')),
        TextField(controller: _musloController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Muslo (cm)', hintText: 'Opcional')),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _agregarRegistro, child: const Text('Guardar Medidas')),
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
                      return SideTitleWidget(axisSide: meta.axisSide, child: Text(DateFormat('dd/MM').format(fecha), style: const TextStyle(fontSize: 10)));
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