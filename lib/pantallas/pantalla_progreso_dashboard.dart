import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:msa/providers/entrenamiento_provider.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/medida_provider.dart';
import 'package:msa/providers/water_provider.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:msa/models/medida.dart'; // Importamos el modelo de Medida

class PantallaProgresoDashboard extends StatelessWidget {
  const PantallaProgresoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos todos los providers que necesitamos para obtener los datos
    final medidaProvider = context.watch<MedidaProvider>();
    final entrenamientoProvider = context.watch<EntrenamientoProvider>();
    final foodProvider = context.watch<FoodProvider>();
    final waterProvider = context.watch<WaterProvider>();

    return Scaffold(
      body: (medidaProvider.isLoading || !entrenamientoProvider.isInitialized)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tu Progreso", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  _buildChartCard(
                    context,
                    title: "Ingesta de Agua (Últimos 7 días)",
                    chart: _buildWaterChart(context, waterProvider),
                  ),
                  const SizedBox(height: 24),

                  _buildChartCard(
                    context,
                    title: "Evolución del Peso (kg)",
                    chart: _buildWeightChart(context, medidaProvider),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildChartCard(
                    context,
                    title: "Volumen de Entrenamiento (Últimos 7 días)",
                    chart: _buildVolumeChart(context, entrenamientoProvider),
                  ),
                  
                  const SizedBox(height: 24),

                  _buildChartCard(
                    context,
                    title: "Ingesta Calórica (Últimos 7 días)",
                    chart: _buildCaloriesChart(context, foodProvider),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChartCard(BuildContext context, {required String title, required Widget chart}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterChart(BuildContext context, WaterProvider provider) {
    final waterData = provider.getIngestaUltimos7Dias();
    if (waterData.values.every((v) => v == 0)) {
      return const Center(child: Text("No hay datos de ingesta de agua en los últimos 7 días."));
    }
    final sortedData = waterData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: sortedData.mapIndexed((index, entry) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.blue,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = sortedData[value.toInt()].key;
                final text = Text(DateFormat('d/M').format(date), style: const TextStyle(fontSize: 10));
                return SideTitleWidget(axisSide: meta.axisSide, child: text);
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context, MedidaProvider provider) {
    if (provider.registros.length < 2) {
      return const Center(child: Text("Necesitas al menos 2 registros de peso para ver el gráfico."));
    }
    final List<Medida> registrosOrdenados = provider.registros.toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: registrosOrdenados.map((medida) {
              return FlSpot(medida.fecha.millisecondsSinceEpoch.toDouble(), medida.peso);
            }).toList(),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final fecha = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(DateFormat('dd/MM').format(fecha), style: const TextStyle(fontSize: 10)));
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Colors.grey, strokeWidth: 0.4);
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
  
  Widget _buildVolumeChart(BuildContext context, EntrenamientoProvider provider) {
    final volumenData = provider.getVolumenUltimos7Dias();
    if (volumenData.values.every((v) => v == 0)) {
      return const Center(child: Text("No hay datos de volumen de entrenamiento en los últimos 7 días."));
    }
    final sortedData = volumenData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: sortedData.mapIndexed((index, entry) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Theme.of(context).colorScheme.secondary,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = sortedData[value.toInt()].key;
                final text = Text(DateFormat('d/M').format(date), style: const TextStyle(fontSize: 10));
                return SideTitleWidget(axisSide: meta.axisSide, child: text);
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildCaloriesChart(BuildContext context, FoodProvider provider) {
    final caloriasData = provider.getCaloriasUltimos7Dias();
    if (caloriasData.values.every((v) => v == 0)) {
      return const Center(child: Text("No hay datos de ingesta calórica en los últimos 7 días."));
    }
    final sortedData = caloriasData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: sortedData.mapIndexed((index, entry) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.orange,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = sortedData[value.toInt()].key;
                final text = Text(DateFormat('d/M').format(date), style: const TextStyle(fontSize: 10));
                return SideTitleWidget(axisSide: meta.axisSide, child: text);
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}