import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/dashboard.dart';
import '../theme/app_theme.dart';

class MonthlyCashChart extends StatelessWidget {
  const MonthlyCashChart({super.key, required this.points});

  final List<MonthlyPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Upload transactions to see monthly trends.')),
      );
    }
    final last = points.length > 12 ? points.sublist(points.length - 12) : points;
    return SizedBox(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 24, left: 8),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: last.length > 1 ? (last.length - 1).toDouble() : 1,
            lineTouchData: const LineTouchData(enabled: true),
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= last.length) return const SizedBox.shrink();
                    final short = last[i].month.split(' ').first;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(short, style: const TextStyle(fontSize: 9)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}k', style: const TextStyle(fontSize: 10)),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < last.length; i++)
                    FlSpot(i.toDouble(), last[i].revenueRm / 1000),
                ],
                color: AppTheme.teal,
                barWidth: 3,
                dotData: const FlDotData(show: true),
              ),
              LineChartBarData(
                spots: [
                  for (var i = 0; i < last.length; i++)
                    FlSpot(i.toDouble(), last[i].expenseRm / 1000),
                ],
                color: Colors.orange.shade700,
                barWidth: 3,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
