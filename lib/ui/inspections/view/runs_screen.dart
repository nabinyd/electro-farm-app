import 'package:electro_farm/core/utils/responsive_padding.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/ui/inspections/providers/inpection_run_provider.dart';
import 'package:electro_farm/ui/inspections/view/frame_screen.dart';
import 'package:electro_farm/ui/inspections/view/report_screen.dart';
import 'package:electro_farm/ui/inspections/view/widgets/badges.dart';
import 'package:electro_farm/ui/inspections/view/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RunsScreen extends StatefulWidget {
  const RunsScreen({super.key});

  @override
  State<RunsScreen> createState() => _RunsScreenState();
}

class _RunsScreenState extends State<RunsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RunsProvider>().fetchRunsIfEmpty(robotId: "agribot-01");
    });
  }

  @override
  Widget build(BuildContext context) => const _RunsView();
}

class _RunsView extends StatelessWidget {
  const _RunsView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RunsProvider>();

    Future<void> onRefresh() async {
      await context.read<RunsProvider>().fetchRuns(robotId: "agribot-01");
    }

    return Scaffold(
      appBar: ElectrofarmAppBar(
        title: "Inspection ",
        actions: [
          IconButton(
            onPressed: () => onRefresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: AppPadding.allMD,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: p.loading
              ? const Center(child: CircularProgressIndicator())
              : p.error != null
              ? _ErrorView(msg: p.error!)
              : p.runs.isEmpty
              ? const _EmptyView()
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: p.runs.length,
                  itemBuilder: (_, i) {
                    final r = p.runs[i];
                    final shortId = r.runId.length >= 8
                        ? r.runId.substring(0, 8)
                        : r.runId;

                    return ListTile(
                      title: Text(
                        "Run $shortId",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      trailing: StatusBadge(status: r.status),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // // ✅ Meta chips instead of _kv rows
                          // Wrap(
                          //   spacing: 8,
                          //   runSpacing: 8,
                          //   children: [
                          //     _InfoChip(
                          //       icon: Icons.smart_toy_outlined,
                          //       label: "Robot: ${r.robotId}",
                          //     ),
                          //     // _InfoChip(
                          //     //   icon: Icons.agriculture_outlined,
                          //     //   label: "Field: ${r.fieldId}",
                          //     // ),
                          //   ],
                          // ),
                          const SizedBox(height: 10),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              value: (r.progress).clamp(0.0, 1.0),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ✅ Stats chips (no Row overflow)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: Icons.photo_library_outlined,
                                label:
                                    "Frames: ${r.doneFrames}/${r.totalFrames}",
                              ),
                              _InfoChip(
                                icon: Icons.error_outline,
                                label: "Failed: ${r.failedFrames}",
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ✅ Buttons: Wrap (so they go next line on small width)
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ReportScreen(runId: r.runId),
                                    ),
                                  );
                                },
                                child: const Text("Open Report"),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          FramesScreen(runId: r.runId),
                                    ),
                                  );
                                },
                                child: const Text("Frames"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              k,
              style: const TextStyle(color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "No inspection runs yet.\nStart a run and upload frames from the robot.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String msg;
  const _ErrorView({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
