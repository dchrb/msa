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
  String _graficoSeleccionado = 'peso';

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
            const SizedBox(height: 20),
            _buildCurrentIMCSummary(profileProvider),
            const SizedBox(height: 30),
            _buildMeasurementForm(medidaProvider, profileProvider),
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
    if (profileProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!profileProvider.perfilCreado) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text("Crea tu perfil para empezar"),
          subtitle: Text("Ve a 'Editar Perfil' en el menú lateral."),
        ),
      );
    }
    
    final profile = profileProvider.profile!;
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mi Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Nombre: ${profile.name}'),
            Text('Altura: ${profile.height} cm'),
            Text('Peso Actual: ${profile.currentWeight} kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentIMCSummary(ProfileProvider profileProvider) {
    if (!profileProvider.perfilCreado) return const SizedBox.shrink();

    final profile = profileProvider.profile!;
    final double alturaEnMetros = profile.height / 100;
    if (alturaEnMetros == 0) return const SizedBox.shrink();
    
    final double imc = profile.currentWeight / (alturaEnMetros * alturaEnMetros);
    final categoria = _getIMCCategory(imc);

    return Card(
      color: categoria.item2.withAlpha(26),
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

  Tuple2<String, Color> _getIMCCategory(double imc) {
    if (imc < 18.5) return const Tuple2('Bajo peso', Colors.blue);
    if (imc < 25) return const Tuple2('Peso normal', Colors.green);
    if (imc < 30) return const Tuple2('Sobrepeso', Colors.orange);
    return const Tuple2('Obesidad', Colors.red);
  }
  
  Widget _buildMeasurementForm(MedidaProvider medidaProvider, ProfileProvider profileProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Nuevo Registro de Medidas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildSingleMeasureInput(
          tipo: 'peso',
          label: 'Peso (kg)',
          medidaProvider: medidaProvider,
          profileProvider: profileProvider,
        ),
        _buildSingleMeasureInput(
          tipo: 'pecho',
          label: 'Pecho (cm)',
          medidaProvider: medidaProvider,
        ),
        _buildSingleMeasureInput(
          tipo: 'brazo',
          label: 'Brazo (cm)',
          medidaProvider: medidaProvider,
        ),
        _buildSingleMeasureInput(
          tipo: 'cintura',
          label: 'Cintura (cm)',
          medidaProvider: medidaProvider,
        ),
        _buildSingleMeasureInput(
          tipo: 'caderas',
          label: 'Caderas (cm)',
          medidaProvider: medidaProvider,
        ),
        _buildSingleMeasureInput(
          tipo: 'muslo',
          label: 'Muslo (cm)',
          medidaProvider: medidaProvider,
        ),
      ],
    );
  }

  Widget _buildSingleMeasureInput({
    required String tipo,
    required String label,
    required MedidaProvider medidaProvider,
    ProfileProvider? profileProvider,
  }) {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: label,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              final valor = double.tryParse(controller.text);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              if (valor != null && valor > 0) {
                medidaProvider.agregarMedidas({tipo: valor}, DateTime.now());
                if (tipo == 'peso' && profileProvider != null) {
                  profileProvider.actualizarPesoActual(valor);
                }
                controller.clear();
                FocusScope.of(context).unfocus();
                scaffoldMessenger.showSnackBar(SnackBar(content: Text('Registro de $label guardado.')));
              } else {
                scaffoldMessenger.showSnackBar(SnackBar(content: Text('Ingresa un valor válido para $label.')));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChartSection(List<Medida> registros) {
    final registrosFiltrados = registros.where((m) => m.tipo == _graficoSeleccionado).toList()..sort((a,b) => a.fecha.compareTo(b.fecha));

    if (registrosFiltrados.length < 2) {
      return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 20.0), child: Text('Necesitas al menos 2 registros de "$_graficoSeleccionado" para ver el gráfico.')));
    }

    final spots = registrosFiltrados.map((medida) {
      return FlSpot(medida.fecha.millisecondsSinceEpoch.toDouble(), medida.valor);
    }).toList();

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
                  getTooltipColor: (spot) => Colors.blueGrey.withAlpha(204),
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
                      return Text(DateFormat('dd/MM').format(fecha), style: const TextStyle(fontSize: 10));
                    }, reservedSize: 30, interval: interval)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots, isCurved: true, color: Theme.of(context).primaryColor, barWidth: 3, dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Theme.of(context).primaryColor.withAlpha(77)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(List<Medida> todosLosRegistros, MedidaProvider medidaProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Historial de Registros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todosLosRegistros.length,
          itemBuilder: (context, index) {
            final medida = todosLosRegistros[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text('${medida.tipo.toUpperCase()}: ${medida.valor.toStringAsFixed(1)}'),
                subtitle: Text(DateFormat('dd/MM/yyyy - hh:mm a', 'es_ES').format(medida.fecha)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(medida, medidaProvider)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                        _showDeleteConfirmationDialog(medida.id, medidaProvider);
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

  void _showDeleteConfirmationDialog(String medidaId, MedidaProvider medidaProvider) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Eliminar Registro'),
          content: const Text('¿Estás seguro de que quieres eliminar este registro?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                medidaProvider.eliminarMedida(medidaId);
                Navigator.of(ctx).pop();
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
    );
  }

  void _showEditDialog(Medida medida, MedidaProvider medidaProvider) {
    final editController = TextEditingController(text: medida.valor.toString());

    showDialog(context: context, builder: (ctx) => AlertDialog(
        title: Text('Editar ${medida.tipo}'),
        content: TextField(
          controller: editController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Nuevo valor (${medida.tipo == 'peso' ? 'kg' : 'cm'})'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final newValue = double.tryParse(editController.text);
              if (newValue != null && newValue > 0) {
                final newMedida = Medida(id: medida.id, fecha: medida.fecha, tipo: medida.tipo, valor: newValue);
                medidaProvider.editarMedida(newMedida);
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
