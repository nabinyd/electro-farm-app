import 'package:electro_farm/core/utils/responsive_padding.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:electro_farm/providers/telemetry_provider.dart';
import 'package:electro_farm/services/socket_service.dart';
import 'package:electro_farm/ui/widgets/premium_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManualControlScreen extends StatelessWidget {
  const ManualControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TelemetryProvider>();
    final t = tp.latest;

    final lidar = t?.lidar;
    final front = lidar?.minFront;

    final blocked = front != null && front > 0 && front < 0.5;

    return Scaffold(
      appBar: ElectrofarmAppBar(title: "Manual Control", showBackButton: true),
      body: Padding(
        padding: AppPadding.allMD,
        child: Column(
          children: [
            PremiumCard(
              title: "Safety Status",
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black12),
                  color: blocked
                      ? const Color(0xFFFFE3E3)
                      : Colors.black.withValues(alpha: .03),
                ),
                child: Text(
                  blocked ? "OBSTACLE CLOSE" : "CLEAR",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: blocked ? const Color(0xFFB00020) : Colors.black87,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _kv(
                    "Front",
                    front == null ? "—" : "${front.toStringAsFixed(2)} m",
                  ),
                  _kv(
                    "Left",
                    lidar == null
                        ? "—"
                        : "${lidar.minLeft?.toStringAsFixed(2)} m",
                  ),
                  _kv(
                    "Right",
                    lidar == null
                        ? "—"
                        : "${lidar.minRight?.toStringAsFixed(2)} m",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            PremiumCard(
              title: "Emergency Stop",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "This will stop the robot immediately.\n(Phase-2: wired to /cmd_vel = 0 and motor stop)",
                    style: TextStyle(color: AppColors.onSurface),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: "STOP ROBOT",
                icon: Icon(Icons.stop_circle),
                onPressed: () {
                  // Phase-1: UI only
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("STOP pressed (wire command in Phase-2)"),
                    ),
                  );
                },
                isDisabled: tp.status != SocketStatus.connected,
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: "Back to Home",
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
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
