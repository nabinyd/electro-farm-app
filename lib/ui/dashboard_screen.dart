import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/telemetry_provider.dart';
import 'widgets/status_chip.dart';
import 'widgets/telemetry_cards.dart';
import 'widgets/speed_chart.dart';
import 'widgets/path_view.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TelemetryProvider>();
    final latest = p.latest;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AgriBot Telemetry Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: StatusChip(status: p.status)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => p.connect(),
                    icon: const Icon(Icons.link),
                    label: const Text("Connect"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => p.disconnect(),
                    icon: const Icon(Icons.link_off),
                    label: const Text("Disconnect"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (latest == null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Text(
                  "No telemetry received yet.\nStart the backend + ROS2 bridge and press Connect.",
                  style: TextStyle(fontSize: 14),
                ),
              )
            else ...[
              TelemetryCards(t: latest),
              const SizedBox(height: 14),

              // Only show these when you start sending odom/speed
              if (latest.speedMps != null) ...[
                SpeedChart(history: p.history.toList()),
                const SizedBox(height: 14),
              ],
              if (latest.odom != null) ...[
                PathView(history: p.history.toList()),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
