import 'package:electro_farm/models/telemetry_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpeedChart extends StatelessWidget {
  final List<Telemetry> history;
  const SpeedChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final points = <FlSpot>[];
    for (int i = 0; i < (history.length < 20 ? history.length : 20); i++) {
      points.add(FlSpot(i.toDouble(), history[i].speedMps ?? 0.0));
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Speed (m/s)",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: true,
                    dotData: const FlDotData(show: false),
                    barWidth: 3,
                    curveSmoothness: 0.2,
                    color: Colors.blue,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                    aboveBarData: BarAreaData(show: false),
                    lineChartStepData: LineChartStepData(stepDirection: 1),
                    // dashArray: [5, 5],
                    show: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
