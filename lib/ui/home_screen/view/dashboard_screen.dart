import 'package:electro_farm/core/utils/button_types.dart';
import 'package:electro_farm/core/utils/responsive_padding.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:electro_farm/models/telemetry_model.dart';
import 'package:electro_farm/providers/telemetry_provider.dart';
import 'package:electro_farm/services/socket_service.dart';
import 'package:electro_farm/ui/widgets/path_view.dart';
import 'package:electro_farm/ui/widgets/speed_chart.dart';
import 'package:electro_farm/ui/widgets/telemetry_cards.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TelemetryProvider>();
    final latest = p.latest;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: ElectrofarmAppBar(
        title: "Dashboard",
        backgroundColor: cs.primary,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top summary strip (sticky feel)
            SliverToBoxAdapter(
              child: Padding(
                padding: AppPadding.allMD,
                child: _TopHeader(
                  latest: latest,
                  status: p.status,
                  onConnect: p.connect,
                  onDisconnect: p.disconnect,
                ),
              ),
            ),

            // Main content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (latest == null) ...[
                    _EmptyStateCard(
                      title: "Waiting for telemetry…",
                      subtitle:
                          "Start Flask SocketIO backend + ROS2 bridge,\nthen tap Connect.",
                      onConnect: p.connect,
                    ),
                    const SizedBox(height: 14),
                    _TipsCard(),
                  ] else ...[
                    // Primary cards
                    TelemetryCards(t: latest),
                    const SizedBox(height: 14),

                    // Charts
                    _SectionHeader(
                      title: "Live Charts",
                      subtitle: "Realtime robot motion + sensor overview",
                      icon: Icons.insights_rounded,
                    ),
                    const SizedBox(height: 10),

                    // Speed chart: show always, it can use 0.0 values too
                    _CardShell(child: SpeedChart(history: p.history.toList())),
                    const SizedBox(height: 14),

                    // Path view
                    _CardShell(child: PathView(history: p.history.toList())),
                    const SizedBox(height: 14),

                    // Debug / raw info (optional)
                    _SectionHeader(
                      title: "Diagnostics",
                      subtitle: "Connection + stream quality",
                      icon: Icons.health_and_safety_rounded,
                    ),
                    const SizedBox(height: 10),
                    _DiagnosticsCard(latest: latest, status: p.status),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- Premium UI Blocks ----------

// MARK: - Top header
class _TopHeader extends StatelessWidget {
  final dynamic status;
  final Telemetry? latest;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _TopHeader({
    required this.latest,
    required this.status,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final hasData = latest != null;
    final robotId = hasData ? (latest?.robotId ?? "unknown") : "—";
    final speed = hasData ? (latest?.speedMps ?? 0.0) : 0.0;
    final danger = hasData ? (latest?.obstacleDanger ?? false) : false;

    return Container(
      padding: AppPadding.allMD,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: cs.primary.withValues(alpha: .12),
                ),
                child: Icon(Icons.agriculture_rounded, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Realtime Telemetry",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Robot: $robotId",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick action
              CustomButton(
                text: "Connect",
                onPressed: onConnect,
                isDisabled: !hasData,
                isLoading: status == SocketStatus.connecting,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Metric chips row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,

            children: [
              _MetricChip(
                icon: Icons.speed_rounded,
                label: "Speed",
                value: "${speed.toStringAsFixed(2)} m/s",
              ),
              _MetricChip(
                icon: Icons.location_on_rounded,
                label: "Pose",
                value: hasData
                    ? "x:${latest?.x.toStringAsFixed(2)}  y:${latest?.y.toStringAsFixed(2)}"
                    : "—",
              ),
              _MetricChip(
                icon: Icons.radar_rounded,
                label: "Obstacle",
                value: danger ? "Danger" : "Clear",
                tone: danger ? _ChipTone.danger : _ChipTone.ok,
              ),
              _MetricChip(
                icon: Icons.timer_rounded,
                label: "Stream",
                value: hasData && (latest?.isStale.call() == true)
                    ? "Stale"
                    : "Live",
                tone: hasData && (latest?.isStale.call() == true)
                    ? _ChipTone.warn
                    : _ChipTone.ok,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Disconnect row (secondary)
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: "Disconnect",
                  onPressed: onDisconnect,
                  type: ButtonType.outline,
                  isDisabled: !hasData,
                  isLoading: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  text: "Reconnect",
                  onPressed: () {
                    onDisconnect();
                    onConnect();
                  },
                  isDisabled: !hasData,
                  isLoading: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, color: cs.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .6)),
      ),
      child: child,
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onConnect;

  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.onPrimary,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .6)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withValues(alpha: .12),
            ),
            child: Icon(Icons.sensors_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CustomButton(text: "Connect", onPressed: onConnect),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.onPrimary,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick checklist",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _bullet("Backend running on 0.0.0.0:5000 (SocketIO)"),
          _bullet("Pi bridge connected and emitting telemetry"),
          _bullet("Phone/PC on same network (Wi-Fi/LAN)"),
          _bullet("CORS enabled + websocket transport allowed"),
        ],
      ),
    );
  }

  Widget _bullet(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
      ],
    ),
  );
}

class _DiagnosticsCard extends StatelessWidget {
  final dynamic latest;
  final dynamic status;

  const _DiagnosticsCard({required this.latest, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final ts = latest.ts as DateTime;
    final ageSec = DateTime.now().difference(ts).inSeconds;
    final lidarCount = latest.lidar?.count ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          _kv("Last packet age", "${ageSec}s"),
          _kv("LiDAR points", "$lidarCount"),
          _kv(
            "IMU gyro |z|",
            latest.imu?.angVel.z.abs().toStringAsFixed(3) ?? "—",
          ),
          const SizedBox(height: 10),
          Text(
            "Tip: If age keeps increasing, your socket is connected but bridge stopped emitting.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
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

enum _ChipTone { ok, warn, danger, neutral }

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final _ChipTone tone;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    this.tone = _ChipTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    switch (tone) {
      case _ChipTone.ok:
        bg = Colors.green.withValues(alpha: .12);
        fg = Colors.green[800]!;
        break;
      case _ChipTone.warn:
        bg = Colors.orange.withValues(alpha: 0.15);
        fg = Colors.orange[900]!;
        break;
      case _ChipTone.danger:
        bg = Colors.red.withValues(alpha: 0.12);
        fg = Colors.red[800]!;
        break;
      case _ChipTone.neutral:
      default:
        bg = cs.surface;
        fg = cs.onSurface;
    }

    return Container(
      padding: AppPadding.allMD,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: fg.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: fg,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
