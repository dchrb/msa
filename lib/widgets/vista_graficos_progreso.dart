import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:msa/providers/medida_provider.dart';
import 'package:fl_chart/fl_chart.dart'; // 1. Importar la librería de gráficos
import 'dart:math';

class VistaGraficosProgreso extends StatefulWidget {
  const VistaGraficosProgreso({super.key});

  @override
  State<VistaGraficosProgreso> createState() => _VistaGraficosProgresoState();
}

// Se ha eliminado el Scaffold y la AppBar interna para que se integre mejor
class _VistaGraficosProgresoState extends State<VistaGraficosProgreso> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withAlpha(178),
          tabs: const [
            Tab(text: 'Peso'),
            Tab(text: 'Medidas'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: _GraficoPeso(),
              ),
              Center(child: Text('Gráficos de Medidas Corporales - Próximamente')),
            ],
          ),
        ),
      ],
    );
  }
}

class _GraficoPeso extends StatelessWidget {
  const _GraficoPeso();

  @override
  Widget build(BuildContext context) {
    final medidaProvider = context.watch<MedidaProvider>();
    // Asegurarse de que los registros estén ordenados por fecha
    final registrosPeso = medidaProvider.registros
        .where((m) => m.tipo == 'peso')
        .toList()..sort((a, b) => a.fecha.compareTo(b.fecha));

    if (registrosPeso.length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Necesitas al menos dos registros de peso para ver un gráfico de progreso.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // 2. Procesar los datos para el gráfico
    final spots = registrosPeso.map((registro) {
      // El eje X será el timestamp de la fecha, el eje Y será el peso
      return FlSpot(registro.fecha.millisecondsSinceEpoch.toDouble(), registro.valor);
    }).toList();

    // Calcular los valores mínimos y máximos para los ejes, con un poco de margen
    final minX = spots.first.x;
    final maxX = spots.last.x;
    final minY = registrosPeso.map((e) => e.valor).reduce(min);
    final maxY = registrosPeso.map((e) => e.valor).reduce(max);
    final yPadding = (maxY - minY) * 0.2; // 20% de margen vertical

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Evolución del Peso', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          // 3. Reemplazar el Placeholder con el widget LineChart
          AspectRatio(
            aspectRatio: 1.7,
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: minY - yPadding,
                maxY: maxY + yPadding,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withAlpha(51), strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, 
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}kg ', style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (maxX - minX) / 4, // Mostrar ~5 etiquetas de fecha
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withAlpha(51),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text('Historial Reciente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: registrosPeso.length,
              itemBuilder: (context, index) {
                // Invertir el índice para mostrar el más reciente primero
                final registro = registrosPeso[registrosPeso.length - 1 - index];
                return ListTile(
                  leading: const Icon(Icons.monitor_weight_outlined),
                  title: Text('${registro.valor.toStringAsFixed(1)} kg'),
                  subtitle: Text(DateFormat('dd MMMM yyyy', 'es_ES').format(registro.fecha)),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
