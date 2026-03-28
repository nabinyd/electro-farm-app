import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/providers/control_bridge_provider.dart';
import 'package:electro_farm/providers/esp_camera_provider.dart';
import 'package:electro_farm/providers/telemetry_provider.dart';
import 'package:electro_farm/services/socket_service.dart';
import 'package:electro_farm/ui/flow/screens/arm_controller_screen.dart';
import 'package:electro_farm/ui/flow/screens/esp_camera_screen.dart';
import 'package:electro_farm/ui/home_screen/task_selection/task_selection_screen.dart';
import 'package:electro_farm/ui/home_screen/view/manual_control_screen.dart';
import 'package:electro_farm/ui/weather/views/weather_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:electro_farm/ui/widgets/premium_widget.dart';

enum FarmTask { spray, inspect }

String taskLabel(FarmTask t) {
  switch (t) {
    case FarmTask.spray:
      return "Spraying";
    case FarmTask.inspect:
      return "Crop Inspection";
  }
}

IconData taskIcon(FarmTask t) {
  switch (t) {
    case FarmTask.spray:
      return Icons.water_drop;
    case FarmTask.inspect:
      return Icons.visibility;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FarmTask? lastTask;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TelemetryProvider>().connect();
    });
  }

  String _lastUpdateText(TelemetryProvider tp) {
    final t = tp.latest;
    if (t == null) return "No data";
    final diff = DateTime.now().difference(t.ts);
    if (diff.inSeconds < 2) return "Live";
    if (diff.inSeconds < 60) return "Live • ${diff.inSeconds}s ago";
    return "Last update • ${diff.inMinutes}m ago";
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TelemetryProvider>();
    final t = tp.latest;
    final imu = t?.imu;
    final lidar = t?.lidar;

    String speedText() {
      final v = t?.speedMps;
      if (v == null) return "0.00";
      return "${v.toStringAsFixed(2)} m/s";
    }

    String accelMag() {
      if (imu == null) return "0.00";
      return imu.linAcc.magnitude().toStringAsFixed(2);
    }

    String frontObs() {
      if (lidar == null) return "—";
      return "${lidar.minFront?.toStringAsFixed(2)} m";
    }

    // Mark: - Build UI
    return Scaffold(
      appBar: ElectrofarmAppBar(
        title: "Welcome, Farmer!",
        showBackButton: false,
        showLogoutButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Feed card
              _LiveFeedCard(
                telemetryProvider: context.read<TelemetryProvider>(),
              ),
              const SizedBox(height: 32),

              // Quick Actions
              _QuickActionsCard(),
              const SizedBox(height: 40),

              _ControlPanel(),
              const SizedBox(height: 40),

              // Telemetry Grid
              _TelemetryGrid(
                speed: speedText(),
                accel: accelMag(),
                frontObs: frontObs(),
                gpsAcc: _lastUpdateText(tp),
              ),
              const SizedBox(height: 48),

              // Secondary Data Section (Asymmetrical)
              _OperationalMapCard(),
              const SizedBox(height: 48),

              PremiumCard(
                title: "Quick Tips",
                // subtitle: "For smooth connection & operation",
                child: Column(
                  children: const [
                    _TipRow(
                      icon: Icons.wifi_rounded,
                      text: "Keep robot + phone on the same Wi-Fi network.",
                    ),
                    SizedBox(height: 10),
                    _TipRow(
                      icon: Icons.link_rounded,
                      text: "If connection drops, restart ROS bridge first.",
                    ),
                    SizedBox(height: 10),
                    _TipRow(
                      icon: Icons.shield_rounded,
                      text: "Manual mode can stop the robot instantly.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- UI Pieces ----------

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: - Reusable UI components
class _LiveFeedCard extends StatelessWidget {
  const _LiveFeedCard({required this.telemetryProvider});
  final TelemetryProvider telemetryProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Consumer<EspCameraProvider>(
              builder: (context, camera, _) {
                final hasFrame = camera.latestFrameBytes != null;
                final isConnected =
                    telemetryProvider.status == SocketStatus.connected;

                if (isConnected && hasFrame) {
                  return const EspCameraView();
                }

                /// fallback UI
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/icon/electrofarm-logo.png',
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.3),
                    ),
                    const Center(
                      child: Text(
                        "Waiting for camera...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Status overlay
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(200),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.onPrimary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STATUS',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: AppColors.onPrimary.withValues(alpha: .7),
                        ),
                      ),
                      Text(
                        telemetryProvider.status == SocketStatus.connected
                            ? "Connected"
                            : telemetryProvider.status ==
                                  SocketStatus.connecting
                            ? "Connecting..."
                            : "Disconnected",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color:
                              telemetryProvider.status == SocketStatus.connected
                              ? Colors.green
                              : telemetryProvider.status ==
                                    SocketStatus.connecting
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 16,
            child: Container(
              width: 300, // ✅ FIX: constrain width
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: .5),
                ),
              ),
              child: WeatherCard(),
            ),
          ),
          // Telemetry overlay
          // Positioned(
          //   bottom: 24,
          //   right: 24,
          //   child: Container(
          //     width: 240, // ✅ FIX: constrain width
          //     padding: const EdgeInsets.all(20),
          //     decoration: BoxDecoration(
          //       color: Colors.white.withValues(alpha: .8),
          //       borderRadius: BorderRadius.circular(16),
          //       border: Border.all(color: Colors.white.withValues(alpha: .2)),
          //     ),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'LIVE TELEMETRY',
          //           style: GoogleFonts.inter(
          //             fontSize: 10,
          //             fontWeight: FontWeight.bold,
          //             letterSpacing: 0.5,
          //             color: AppColors.onSurface.withValues(alpha: .7),
          //           ),
          //         ),
          //         const SizedBox(height: 16),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text(
          //               'Battery',
          //               style: GoogleFonts.inter(
          //                 fontSize: 12,
          //                 color: AppColors.onSurface,
          //               ),
          //             ),
          //             Text(
          //               '84%',
          //               style: GoogleFonts.manrope(
          //                 fontSize: 20,
          //                 fontWeight: FontWeight.bold,
          //                 color: AppColors.primary,
          //               ),
          //             ),
          //           ],
          //         ),
          //         const SizedBox(height: 6),
          //         ClipRRect(
          //           borderRadius: BorderRadius.circular(999),
          //           child: LinearProgressIndicator(
          //             value: 0.84,
          //             backgroundColor: AppColors.primary.withOpacity(0.2),
          //             color: AppColors.primary,
          //             minHeight: 6,
          //           ),
          //         ),
          //         const SizedBox(height: 12),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text(
          //               'GPS Accuracy',
          //               style: GoogleFonts.inter(
          //                 fontSize: 12,
          //                 color: AppColors.onSurface,
          //               ),
          //             ),
          //             Text(
          //               '0.02m',
          //               style: GoogleFonts.inter(
          //                 fontWeight: FontWeight.bold,
          //                 color: AppColors.primary,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Control Hub',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unit agribot-01 is currently in idle state. Select a protocol to begin operation.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurface.withValues(alpha: .7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TaskSelectionScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Task',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ArmControlScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  side: BorderSide(color: AppColors.primary, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Arm Controller',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.settings_suggest_sharp, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ManualControlScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onSecondary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emergency_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Manual Emergency',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TelemetryGrid extends StatelessWidget {
  const _TelemetryGrid({
    required this.speed,
    required this.accel,
    required this.frontObs,
    required this.gpsAcc,
  });

  final String speed;
  final String accel;
  final String frontObs;
  final String gpsAcc;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _TelemetryTile(
          icon: Icons.speed,
          label: 'Speed',
          value: speed,
          unit: 'km/h',
        ),
        _TelemetryTile(
          icon: Icons.trending_up,
          label: 'Acceleration',
          value: accel,
          unit: 'm/s²',
        ),
        _TelemetryTile(
          icon: Icons.radar,
          label: 'Obstacles',
          value: frontObs,
          unit: '',
          isStatus: true,
        ),
        // _TelemetryTile(
        //   icon: Icons.signal_cellular_alt,
        //   label: 'Signal',
        //   value: gpsAcc,
        //   unit: 'dBm',
        // ),
      ],
    );
  }
}

class _TelemetryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool isStatus;

  const _TelemetryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 4,
        //     offset: const Offset(0, 1),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.secondary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColors.onSurface.withValues(alpha: .7),
                  textStyle: TextStyle(overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(height: 8),
              if (!isStatus)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        textStyle: TextStyle(overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface.withValues(alpha: .7),
                        textStyle: TextStyle(overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: value.toLowerCase().contains('none')
                            ? Colors.green
                            : AppColors.primary,
                        textStyle: TextStyle(overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Path Clear',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OperationalMapCard extends StatelessWidget {
  const _OperationalMapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Operational Map',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Sector A-12',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: EspCameraView(),
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel();

  static const String robotId = "agribot-01";

  @override
  Widget build(BuildContext context) {
    return Consumer<ControlProvider>(
      builder: (context, control, _) {
        final isAuto = control.isAuto;
        final isEmergency = control.isEmergency;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Robot Control",
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAuto ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      control.modeText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 🔹 AUTO / MANUAL Toggle
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isEmergency
                          ? null
                          : () => control.setAuto(robotId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAuto
                            ? Colors.green
                            : Colors.grey[300],
                        foregroundColor: isAuto ? Colors.white : Colors.black,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text("AUTO MODE"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => control.setManual(robotId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isAuto
                            ? Colors.orange
                            : Colors.grey[300],
                        foregroundColor: !isAuto ? Colors.white : Colors.black,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text("MANUAL"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 Emergency Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isEmergency) {
                      control.releaseEmergency(robotId);
                    } else {
                      control.triggerEmergency(robotId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded),
                      const SizedBox(width: 8),
                      Text(
                        isEmergency ? "RELEASE EMERGENCY" : "EMERGENCY STOP",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🔹 Status Info
              Text(
                isEmergency
                    ? "⚠ Emergency active — robot stopped"
                    : isAuto
                    ? "🚜 Autonomous navigation running"
                    : "🧑‍✈️ Manual control active",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurface.withValues(alpha: .7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
