import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:msa/providers/food_provider.dart';
import 'package:msa/providers/water_provider.dart';
import 'dart:math';

class VistaGraficosNutricion extends StatelessWidget {
  const VistaGraficosNutricion({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGraficoCalorias(context),
            const SizedBox(height: 24),
            _buildGraficoMacros(context),
            const SizedBox(height: 24),
            _buildGraficoAgua(context),
          ],
        ),
      );
    });
  }

  Widget _buildGraficoCalorias(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final today = DateTime.now();
    final theme = Theme.of(context);

    final ultimos7dias = List.generate(7, (index) => today.subtract(Duration(days: index))).reversed.toList();
    final dataCalorias = ultimos7dias.map((dia) {
      return {'dia': dia, 'calorias': foodProvider.getCaloriasConsumidasPorFecha(dia)};
    }).toList();

    final barGroups = dataCalorias.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: data['calorias'] as double, color: theme.colorScheme.primary, width: 16, borderRadius: BorderRadius.circular(4)),
        ],
      );
    }).toList();

    final maxY = dataCalorias.map((d) => d['calorias'] as double).fold(0.0, max) * 1.2;

    final chart = AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 1000 : maxY,
          barGroups: barGroups,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withAlpha(51), strokeWidth: 1)),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
              if (value == 0 || value >= meta.max) return const SizedBox.shrink();
              return Text('${value.toInt()} ', style: const TextStyle(fontSize: 10));
            })),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (value, meta) {
              final dia = dataCalorias[value.toInt()]['dia'] as DateTime;
              return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(DateFormat.E('es_ES').format(dia)[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
            })),
          ),
        ),
      ),
    );

    return _buildContenedorGrafico(context: context, titulo: 'Ingesta Calórica (Últimos 7 Días)', content: chart);
  }

  Widget _buildGraficoMacros(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();
    final macrosHoy = foodProvider.getMacrosPorFecha(DateTime.now());

    final totalGramos = (macrosHoy['proteinas'] ?? 0) + (macrosHoy['carbohidratos'] ?? 0) + (macrosHoy['grasas'] ?? 0);

    if (totalGramos == 0) {
      return _buildContenedorGrafico(
        context: context,
        titulo: 'Distribución de Macros (Hoy)',
        content: const AspectRatio(
          aspectRatio: 1.7,
          child: Center(child: Text('No hay datos de macronutrientes para hoy.', style: TextStyle(color: Colors.grey))),
        ),
      );
    }

    final List<PieChartSectionData> sections = [
      PieChartSectionData(value: macrosHoy['proteinas'], title: '${(macrosHoy['proteinas']! / totalGramos * 100).toStringAsFixed(0)}%', color: Colors.green, radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
      PieChartSectionData(value: macrosHoy['carbohidratos'], title: '${(macrosHoy['carbohidratos']! / totalGramos * 100).toStringAsFixed(0)}%', color: Colors.orange, radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
      PieChartSectionData(value: macrosHoy['grasas'], title: '${(macrosHoy['grasas']! / totalGramos * 100).toStringAsFixed(0)}%', color: Colors.redAccent, radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold)),
    ];

    final chart = AspectRatio(
      aspectRatio: 2.2,
      child: Row(
        children: [
          Expanded(
            child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 30, sectionsSpace: 2)),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Indicator(color: Colors.green, text: 'Proteínas'),
              SizedBox(height: 4),
              Indicator(color: Colors.orange, text: 'Carbs'),
              SizedBox(height: 4),
              Indicator(color: Colors.redAccent, text: 'Grasas'),
            ],
          ),
        ],
      ),
    );

    return _buildContenedorGrafico(context: context, titulo: 'Distribución de Macros (Hoy)', content: chart);
  }

  Widget _buildGraficoAgua(BuildContext context) {
    final waterProvider = context.watch<WaterProvider>();
    final today = DateTime.now();

    final ultimos7dias = List.generate(7, (index) => today.subtract(Duration(days: index))).reversed.toList();
    final dataAgua = ultimos7dias.map((dia) {
      return {'dia': dia, 'cantidad': waterProvider.getIngestaPorFecha(dia)};
    }).toList();

    final barGroups = dataAgua.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: data['cantidad'] as double, color: Colors.blue, width: 16, borderRadius: BorderRadius.circular(4)),
        ],
      );
    }).toList();

    final maxY = dataAgua.map((d) => d['cantidad'] as double).fold(0.0, max) * 1.2;

    final chart = AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 2000 : maxY, // Eje Y por defecto a 2000ml (2L)
          barGroups: barGroups,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (maxY == 0 ? 2000 : maxY) / 4, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withAlpha(51), strokeWidth: 1)),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
              if (value == 0 || value >= meta.max) return const SizedBox.shrink();
              return Text('${value.toInt()}ml ', style: const TextStyle(fontSize: 10));
            })),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (value, meta) {
              final dia = dataAgua[value.toInt()]['dia'] as DateTime;
              return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(DateFormat.E('es_ES').format(dia)[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
            })),
          ),
        ),
      ),
    );

    return _buildContenedorGrafico(context: context, titulo: 'Historial de Hidratación (Últimos 7 Días)', content: chart);
  }

  Widget _buildContenedorGrafico({required BuildContext context, required String titulo, required Widget content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(titulo, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 24), content]),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const Indicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
