import 'package:electro_farm/core/utils/button_types.dart';
import 'package:electro_farm/core/utils/responsive_padding.dart';
import 'package:electro_farm/core/utils/toaast_helper.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/telemetry_provider.dart';
import '../../../services/socket_service.dart';
import 'package:electro_farm/ui/widgets/premium_widget.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onStartWork;
  final VoidCallback onManualControl;
  final VoidCallback onReports;
  final VoidCallback onOpenTechDashboard;

  const HomeScreen({
    super.key,
    required this.onStartWork,
    required this.onManualControl,
    required this.onReports,
    required this.onOpenTechDashboard,
  });

  String _lastUpdateText(TelemetryProvider tp) {
    final t = tp.latest;
    if (t == null) return "No telemetry yet";
    final diff = DateTime.now().difference(t.ts);
    if (diff.inSeconds < 2) return "Live • just now";
    if (diff.inSeconds < 60) return "Live • ${diff.inSeconds}s ago";
    return "Last update • ${diff.inMinutes}m ago";
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TelemetryProvider>();
    final t = tp.latest;

    final imu = t?.imu;
    final lidar = t?.lidar;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String speedText() {
      final v = t?.speedMps;
      if (v == null) return "—";
      return "${v.toStringAsFixed(2)} m/s";
    }

    String accelMag() {
      if (imu == null) return "—";
      return imu.linAcc.magnitude().toStringAsFixed(2);
    }

    String frontObs() {
      if (lidar == null) return "—";
      return "${lidar.minFront?.toStringAsFixed(2)} m";
    }

    // Mark: - Build UI
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: ElectrofarmAppBar(
        title: "Home",
        showBackButton: false,
        showLogoutButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // HERO / OVERVIEW
            _HeroCard(
              robotId: t?.robotId ?? "agribot-01",
              status: tp.status,
              subtitle: _lastUpdateText(tp),
              onToggleConnection: () {
                if (tp.status == SocketStatus.connected) {
                  tp.disconnect();
                } else {
                  tp.connect();
                }
              },
            ),

            const SizedBox(height: 14),

            // METRICS GRID
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    title: "Speed",
                    value: speedText(),
                    icon: Icons.speed_rounded,
                    tone: _Tone.neutral,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    title: "Accel Mag",
                    value: accelMag(),
                    icon: Icons.show_chart_rounded,
                    tone: _Tone.neutral,
                    suffix: "m/s²",
                    showSuffixOnlyIfNumeric: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _MetricTile(
              title: "Front Obstacle",
              value: frontObs(),
              icon: Icons.radar_rounded,
              tone:
                  lidar != null &&
                      (lidar.minFront != null && lidar.minFront! < 0.5)
                  ? _Tone.danger
                  : _Tone.ok,
              suffix: "m",
              showSuffixOnlyIfNumeric: true,
              subtitle:
                  lidar != null &&
                      (lidar.minFront != null && lidar.minFront! < 0.5)
                  ? "⚠️ Obstacle too close"
                  : "Path looks clear",
            ),
            const SizedBox(height: 18),

            // PRIMARY ACTIONS
            PremiumCard(
              title: "Start a Task",
              // subtitle: "Spraying • Inspection • Navigation",
              child: Column(
                children: [
                  CustomButton(text: "Select Task", onPressed: onStartWork),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CustomButton(
                        text: "Reports",
                        icon: Icon(Icons.receipt_long_rounded),
                        onPressed: onReports,
                        type: ButtonType.outline,
                      ),
                      const SizedBox(width: 16),
                      CustomButton(
                        text: "Robot Status",
                        icon: Icon(Icons.monitor_rounded),
                        onPressed: () {
                          // Optionally: open a status page later
                          ToastHelper.showInfoToast(
                            "Robot status coming soon!",
                          );
                        },
                        type: ButtonType.outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // MARK:- EMERGENCY
            PremiumCard(
              title: "Emergency Control",
              // subtitle: "Use only when needed (manual override)",
              child: CustomButton(
                text: "Manual (Emergency)",
                icon: Icon(Icons.sports_esports_rounded),
                onPressed: onManualControl,
              ),
            ),

            const SizedBox(height: 14),

            // MARK:- TIPS (more polished)
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

            const SizedBox(height: 14),

            // ADVANCED / DEVELOPER (hidden from farmer main flow)
            _AdvancedSection(onOpenTechDashboard: onOpenTechDashboard),
          ],
        ),
      ),
    );
  }
}

/// ---------- UI Pieces ----------

class _HeroCard extends StatelessWidget {
  final String robotId;
  final SocketStatus status;
  final String subtitle;
  final VoidCallback onToggleConnection;

  const _HeroCard({
    required this.robotId,
    required this.status,
    required this.subtitle,
    required this.onToggleConnection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final connected = status == SocketStatus.connected;

    return Container(
      padding: AppPadding.hMD + AppPadding.vLG,

      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: cs.primary.withValues(alpha: .12),
            ),
            child: Icon(Icons.agriculture_rounded, color: cs.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Robot: $robotId",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CustomButton(
            text: connected ? "Disconnect" : "Connect",
            onPressed: onToggleConnection,
            isLoading:
                status == SocketStatus.connecting ||
                status == SocketStatus.reconnecting,
            type: connected ? ButtonType.danger : ButtonType.primary,
          ),
        ],
      ),
    );
  }
}

enum _Tone { neutral, ok, danger }

class _MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final _Tone tone;

  final String? suffix;
  final bool showSuffixOnlyIfNumeric;

  const _MetricTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.tone,
    this.subtitle,
    this.suffix,
    this.showSuffixOnlyIfNumeric = false,
  });

  bool _isNumeric(String v) => double.tryParse(v.split(" ").first) != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Color fg = AppColors.onBackground;
    Color bg = AppColors.background;
    switch (tone) {
      case _Tone.ok:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success.withValues(alpha: 0.8);
        break;
      case _Tone.danger:
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error.withValues(alpha: 0.8);
        break;
      case _Tone.neutral:
    }

    final showSuffix =
        suffix != null &&
        (!showSuffixOnlyIfNumeric ||
            (showSuffixOnlyIfNumeric && _isNumeric(value)));

    return Container(
      padding: AppPadding.allLG,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: fg.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: fg,
                      ),
                    ),
                    if (showSuffix) ...[
                      const SizedBox(width: 6),
                      Text(
                        suffix!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class _AdvancedSection extends StatefulWidget {
  final VoidCallback onOpenTechDashboard;
  const _AdvancedSection({required this.onOpenTechDashboard});

  @override
  State<_AdvancedSection> createState() => _AdvancedSectionState();
}

class _AdvancedSectionState extends State<_AdvancedSection> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .6)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: const Text("Advanced"),
            subtitle: const Text("Developer tools & detailed telemetry"),
            // trailing: Icon(
            //   open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            // ),
            onTap: () => setState(() => open = !open),
          ),
          // if (open)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButton(
              text: "Open Telemetry Dashboard",
              onPressed: widget.onOpenTechDashboard,
              type: ButtonType.outline,
            ),
          ),
        ],
      ),
    );
  }
}
