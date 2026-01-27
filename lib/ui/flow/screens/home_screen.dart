import 'package:electro_farm/ui/widgets/status_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/telemetry_provider.dart';
import '../../../services/socket_service.dart';

class HomeScreen extends StatelessWidget {
  final int totalRows;
  final int rowDone;
  final VoidCallback onStartWork;
  final VoidCallback onManualControl;
  final VoidCallback onReports;
  final VoidCallback onOpenTechDashboard;

  const HomeScreen({
    super.key,
    required this.totalRows,
    required this.rowDone,
    required this.onStartWork,
    required this.onManualControl,
    required this.onReports,
    required this.onOpenTechDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TelemetryProvider>();
    final latest = p.latest;

    final isConnected = p.status == SocketStatus.connected;
    final secondsAgo = latest == null
        ? null
        : DateTime.now().difference(latest.ts).inSeconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AgriBot"),
        actions: [
          IconButton(
            tooltip: "Tech Dashboard",
            icon: const Icon(Icons.analytics),
            onPressed: onOpenTechDashboard,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            StatusBanner(
              status: p.status,
              batteryPercent: 82,
              signalText: isConnected ? "Good" : "No Signal",
            ),
            const SizedBox(height: 12),

            // Field summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Field: Potato Plot A",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Progress: $rowDone / $totalRows rows",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          latest == null
                              ? "Last update: —"
                              : "Last update: ${secondsAgo}s ago",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Primary actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStartWork,
                icon: const Icon(Icons.play_arrow),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    "START WORK",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onManualControl,
                icon: const Icon(Icons.gamepad),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    "MANUAL CONTROL",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReports,
                icon: const Icon(Icons.receipt_long),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    "REPORTS",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Connection controls (small)
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Socket: ${p.status.name}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<TelemetryProvider>().connect(),
                  child: const Text("Reconnect"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
