import 'package:electro_farm/services/inspection_service.dart';
import 'package:electro_farm/ui/inspections/providers/inpection_run_provider.dart';
import 'package:electro_farm/ui/inspections/view/widgets/badges.dart';
import 'package:electro_farm/ui/inspections/view/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RunsScreen extends StatelessWidget {
  const RunsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RunsView();
  }
}

class _RunsView extends StatelessWidget {
  const _RunsView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RunsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inspection History",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<RunsProvider>().refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: p.loading
            ? const Center(child: CircularProgressIndicator())
            : p.error != null
            ? _ErrorView(msg: p.error!)
            : p.runs.isEmpty
            ? const _EmptyView()
            : ListView.builder(
                itemCount: p.runs.length,
                itemBuilder: (_, i) {
                  final r = p.runs[i];
                  return SectionCard(
                    title: "Run • ${r.runId.substring(0, 8)}",
                    trailing: StatusBadge(status: r.status),
                    child: Column(
                      children: [
                        _kv("Robot", r.robotId),
                        _kv("Field", r.fieldId),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 10,
                            value: r.progress,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "Frames: ${r.doneFrames}/${r.totalFrames}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const Spacer(),
                            Text(
                              "Failed: ${r.failedFrames}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushNamed("/inspection/report/${r.runId}"),
                                icon: const Icon(Icons.assessment),
                                label: const Text("Open Report"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushNamed("/inspection/frames/${r.runId}"),
                                icon: const Icon(Icons.photo_library),
                                label: const Text("Frames"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
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
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
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
