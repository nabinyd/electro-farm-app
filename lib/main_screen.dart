import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/providers/telemetry_provider.dart';
import 'package:electro_farm/ui/home_screen/home_screen.dart';
import 'package:electro_farm/ui/inspections/providers/inpection_run_provider.dart';
import 'package:electro_farm/ui/inspections/view/report_screen.dart';
import 'package:electro_farm/ui/report/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final _homeNavKey = GlobalKey<NavigatorState>();
  final _reportsNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          Navigator(
            key: _homeNavKey,
            onGenerateRoute: (_) =>
                MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
          Navigator(
            key: _reportsNavKey,
            onGenerateRoute: (_) =>
                MaterialPageRoute(builder: (_) => const InspectionRunsScreen()),
          ),
          Navigator(
            key: GlobalKey<NavigatorState>(),
            onGenerateRoute: (_) =>
                MaterialPageRoute(builder: (_) => const ReportTabScreen()),
          ),
          Navigator(
            key: GlobalKey<NavigatorState>(),
            onGenerateRoute: (_) =>
                MaterialPageRoute(builder: (_) => const Placeholder()),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.primary,
            // gradient: const LinearGradient(
            //   colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            // ),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.green.withOpacity(0.25),
            //     blurRadius: 20,
            //     offset: const Offset(0, 8),
            //   ),
            // ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _index,
              onTap: (i) {
                if (i == _index) {
                  final nav = i == 0
                      ? _homeNavKey.currentState
                      : _reportsNavKey.currentState;
                  nav?.popUntil((r) => r.isFirst);
                } else {
                  setState(() => _index = i);
                }
              },
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              selectedItemColor: AppColors.background,
              unselectedItemColor: Colors.white70,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.agriculture_outlined),
                  activeIcon: Icon(Icons.agriculture),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.task_outlined),
                  activeIcon: Icon(Icons.task),
                  label: "Task",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  activeIcon: Icon(Icons.analytics),
                  label: "Report",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: "Settings",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InspectionRunsScreen extends StatefulWidget {
  const InspectionRunsScreen({super.key});

  @override
  State<InspectionRunsScreen> createState() => _InspectionRunsScreenState();
}

class _InspectionRunsScreenState extends State<InspectionRunsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final robotId = context.read<TelemetryProvider>().latest?.robotId;
      context.read<RunsProvider>().fetchRunsIfEmpty(robotId: robotId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RunsProvider>();
    final robotId = context.watch<TelemetryProvider>().latest?.robotId;
    final cs = Theme.of(context).colorScheme;

    final filteredRuns = robotId == null
        ? p.runs
        : p.runs.where((r) => r.robotId == robotId).toList();

    Widget centeredMessage(String text, {IconData? icon}) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        const Color(0xFFF1F8E9), // light green tint
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.green.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: cs.primary),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.25,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: ElectrofarmAppBar(
        title: "Inspection Runs",
        showLogoutButton: false,
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<RunsProvider>().fetchRuns(robotId: robotId),
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: () {
            if (p.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (p.error != null) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.18)),
                  ),
                  child: Text(
                    p.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (p.runs.isEmpty) {
              return centeredMessage(
                "No inspection runs available.",
                icon: Icons.inbox_outlined,
              );
            }

            if (filteredRuns.isEmpty) {
              return centeredMessage(
                "No inspection runs for the current robot.",
                icon: Icons.smart_toy_outlined,
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<RunsProvider>().fetchRuns(robotId: robotId),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                itemCount: filteredRuns.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final run = filteredRuns[i];
                  final shortId = run.runId.length >= 8
                      ? run.runId.substring(0, 8)
                      : run.runId;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReportScreen(runId: run.runId),
                          ),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.06),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      cs.primary.withOpacity(0.18),
                                      cs.primary.withOpacity(0.08),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: cs.primary.withOpacity(0.18),
                                  ),
                                ),
                                child: Icon(
                                  Icons.smart_toy_outlined,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Main
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Run $shortId",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        _StatusPill(
                                          text: "Completed",
                                          icon: Icons.check_circle_outline,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      children: [
                                        _MiniInfo(
                                          icon: Icons.agriculture,
                                          text: "Field ${run.fieldId}",
                                        ),
                                        _MiniInfo(
                                          icon: Icons.smart_toy,
                                          text: "Robot ${run.robotId}",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Arrow
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }(),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final IconData icon;

  const _StatusPill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.green.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.green),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
