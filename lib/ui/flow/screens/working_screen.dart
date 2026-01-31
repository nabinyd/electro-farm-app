import 'dart:async';
import 'package:electro_farm/core/utils/button_types.dart';
import 'package:electro_farm/core/utils/responsive_padding.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:electro_farm/ui/widgets/premium_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:electro_farm/providers/telemetry_provider.dart';
import 'package:electro_farm/ui/flow/app_flow.dart';

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
  late int rowNow;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    rowNow = widget.initialRowDone;

    // Phase-1: still fake row progress, but UI is real
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
    final tp = context.watch<TelemetryProvider>();
    final t = tp.latest;
    final progress = rowNow / widget.totalRows;

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
      appBar: ElectrofarmAppBar(
        title: "Working: ${widget.task.name}",
        showBackButton: false,
        showLogoutButton: false,
      ),
      body: Padding(
        padding: AppPadding.allMD,
        child: Column(
          children: [
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
                    "${(progress * 100).toStringAsFixed(0)}% completed",
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const Spacer(),

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
                    icon: paused ? Icon(Icons.play_arrow) : Icon(Icons.pause),
                    type: ButtonType.outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: "STOP",
                    onPressed: widget.onStop,
                    icon: const Icon(Icons.stop),
                    type: ButtonType.danger,
                    isDisabled: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            CustomButton(
              text: "MANUAL (Emergency)",
              onPressed: widget.onOpenManual,
            ),
          ],
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
