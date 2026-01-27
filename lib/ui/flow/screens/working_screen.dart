import 'dart:async';
import 'package:electro_farm/providers/telemetry_provider.dart';
import 'package:electro_farm/ui/flow/app_flow.dart';
import 'package:electro_farm/ui/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkingScreen extends StatefulWidget {
  final FarmTask task;
  final int totalRows;
  final int rowDone;

  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onOpenManual;
  final VoidCallback onCompleted;

  const WorkingScreen({
    super.key,
    required this.task,
    required this.totalRows,
    required this.rowDone,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onOpenManual,
    required this.onCompleted,
  });

  @override
  State<WorkingScreen> createState() => _WorkingScreenState();
}

class _WorkingScreenState extends State<WorkingScreen> {
  bool paused = false;
  late int rowNow;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    rowNow = widget.rowDone;

    // Fake progress tick (replace later with mission updates)
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || paused) return;
      setState(() {
        if (rowNow < widget.totalRows) rowNow++;
        if (rowNow >= widget.totalRows) {
          _timer?.cancel();
          widget.onCompleted();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = context.watch<TelemetryProvider>().latest;
    final progress = rowNow / widget.totalRows;

    return Scaffold(
      appBar: AppBar(title: Text(taskLabel(widget.task))),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paused ? "Robot Paused" : "Robot Working",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Row: $rowNow / ${widget.totalRows}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          telemetry == null
                              ? "Speed: —"
                              : "Speed: ${telemetry.speedMps?.toStringAsFixed(2)} m/s",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.battery_full),
                ],
              ),
            ),
            const SizedBox(height: 14),

            ProgressBar(
              value: progress,
              label: "${(progress * 100).toStringAsFixed(0)}%",
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => paused = !paused);
                      if (paused) {
                        widget.onPause();
                      } else {
                        widget.onResume();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(paused ? "RESUME" : "PAUSE"),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onStop,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text("STOP"),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onOpenManual,
                icon: const Icon(Icons.gamepad),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text("MANUAL (Emergency)"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
