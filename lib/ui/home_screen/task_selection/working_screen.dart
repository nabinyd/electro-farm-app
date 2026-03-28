import 'dart:async';
import 'package:electro_farm/core/utils/button_sizes.dart';
import 'package:electro_farm/core/utils/button_types.dart';
import 'package:electro_farm/core/utils/responsive_padding.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:electro_farm/providers/inspection_provider.dart';
import 'package:electro_farm/ui/flow/screens/esp_camera_screen.dart';
import 'package:electro_farm/ui/home_screen/home_screen.dart';
import 'package:electro_farm/ui/widgets/premium_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:electro_farm/providers/telemetry_provider.dart';

class WorkingScreen extends StatefulWidget {
  final FarmTask task;
  final int totalRows;
  final int initialRowDone;

  final VoidCallback onStop;
  final VoidCallback onOpenManual;
  final VoidCallback onCompleted;

  const WorkingScreen({
    super.key,
    required this.task,
    required this.totalRows,
    required this.initialRowDone,
    required this.onStop,
    required this.onOpenManual,
    required this.onCompleted,
  });

  @override
  State<WorkingScreen> createState() => _WorkingScreenState();
}

class _WorkingScreenState extends State<WorkingScreen> {
  bool paused = false;
  late int rowNow = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    if (widget.task == FarmTask.spray) {
      rowNow = widget.initialRowDone;

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
    } else {
      // inspection mode
      final inspection = context.read<InspectionProvider>();
      final telemetry = context.read<TelemetryProvider>();

      inspection.startInspection(
        robotId: telemetry.latest?.robotId ?? "unknown",
        fieldId: "field_123",
        totalFrames: 100,
      );

      _timer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (!mounted || paused) return;

        inspection.refreshStatus();

        if (inspection.status == "done") {
          _timer?.cancel();
          widget.onCompleted();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TelemetryProvider>();
    final t = tp.latest;
    final inspection = context.watch<InspectionProvider>();

    double progress = widget.task == FarmTask.inspect
        ? (inspection.progress / 100)
        : (rowNow / widget.totalRows);

    final speed = t?.speedMps;
    final imu = t?.imu;
    final lidar = t?.lidar;

    String speedText() {
      if (speed == null) return "—";
      return "${speed.toStringAsFixed(2)} m/s";
    }

    String accelText() {
      if (imu == null) return "—";
      return imu.linAcc.magnitude().toStringAsFixed(2);
    }

    String frontText() {
      if (lidar == null) return "—";
      return "${lidar.minFront?.toStringAsFixed(2) ?? "—"} m";
    }

    return Scaffold(
      appBar: ElectrofarmAppBar(title: "Working: ${widget.task.name}"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppPadding.allMD,
            child: Column(
              children: [
                // TODO: replace with real data from telemetry
                // TODO: show report of inspected frame
                PremiumCard(
                  title: paused ? "Paused" : "Working",
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.black12),
                      color: Colors.black.withValues(alpha: .03),
                    ),
                    child: Text(
                      "Row $rowNow / ${widget.totalRows}",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  child: Column(
                    children: [
                      _kv("Speed", speedText()),
                      _kv("Accel Mag", accelText()),
                      _kv("Front Obstacle", frontText()),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                PremiumCard(
                  title: "Progress",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(value: progress, minHeight: 10),
                      const SizedBox(height: 10),
                      Text(
                        widget.task == FarmTask.inspect
                            ? "${inspection.progress.toStringAsFixed(1)}%"
                            : "${(progress * 100).toStringAsFixed(0)}%",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: EspCameraView(),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: paused ? "RESUME" : "PAUSE",
                        onPressed: () {
                          setState(() {
                            paused = !paused;
                          });
                        },
                        icon: paused
                            ? Icon(Icons.play_arrow)
                            : Icon(Icons.pause),
                        type: ButtonType.outline,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        text: "STOP",
                        onPressed: () {
                          final inspection = context.read<InspectionProvider>();

                          if (widget.task == FarmTask.inspect) {
                            inspection.stopInspection();
                          }

                          widget.onStop();
                        },
                        icon: const Icon(Icons.stop),
                        type: ButtonType.danger,
                        isDisabled: false,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                CustomButton(
                  text: "MANUAL (Emergency)",
                  onPressed: widget.onOpenManual,
                  icon: const Icon(Icons.settings_remote),
                  type: ButtonType.primary,
                  width: double.infinity,
                  size: ButtonSize.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
