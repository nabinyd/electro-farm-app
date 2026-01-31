import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:electro_farm/models/inspection_models.dart';
import 'package:electro_farm/ui/inspections/providers/report_provider.dart';
import 'package:electro_farm/ui/inspections/view/frame_screen.dart';
import 'package:electro_farm/ui/inspections/view/widgets/badges.dart';
import 'package:electro_farm/ui/inspections/view/widgets/section_card.dart';
import 'package:electro_farm/ui/inspections/view/widgets/stat_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  final String runId;
  const ReportScreen({super.key, required this.runId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ trigger load once when this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().load(widget.runId);
    });
  }

  @override
  void didUpdateWidget(covariant ReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ if runId changes, refetch
    if (oldWidget.runId != widget.runId) {
      context.read<ReportProvider>().load(widget.runId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ReportView(runId: widget.runId);
  }
}

class _ReportView extends StatelessWidget {
  final String runId;
  const _ReportView({required this.runId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ReportProvider>();

    return Scaffold(
      appBar: ElectrofarmAppBar(
        title: "Inspection Report",
        actions: [
          IconButton(
            onPressed: () => context.read<ReportProvider>().load(runId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: p.loading
            ? const Center(child: CircularProgressIndicator())
            : p.error != null
            ? Center(
                child: Text(
                  p.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
            : p.report == null
            ? const Center(child: Text("No report yet"))
            : _ReportBody(report: p.report!),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  final RunReport report;
  const _ReportBody({required this.report});

  @override
  Widget build(BuildContext context) {
    final r = report;
    final stats = r.stats;
    final topIssues = r.topIssues;
    final llm = r.reportText ?? {};

    final riskLevel = (llm["risk_level"] ?? "medium").toString();
    final summary = (llm["summary"] ?? "Report is generating…").toString();
    final findings = (llm["key_findings"] is List)
        ? (llm["key_findings"] as List).map((e) => e.toString()).toList()
        : <String>[];
    final actions = (llm["priority_actions"] is List)
        ? (llm["priority_actions"] as List).map((e) => e.toString()).toList()
        : <String>[];

    return ListView(
      children: [
        SectionCard(
          title: "Run Overview",
          trailing: StatusBadge(status: r.status),
          child: Column(
            children: [
              _kv("Robot", r.robotId),
              // _kv("Field", r.fieldId),
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
            ],
          ),
        ),

        SectionCard(
          title: "Quick Stats",
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: "Processed",
                      value: "${stats["processed"] ?? 0}",
                      icon: Icons.done_all,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: "Stressed",
                      value: "${stats["stressed_frames"] ?? 0}",
                      icon: Icons.warning_amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: "Healthy",
                      value: "${stats["healthy_frames"] ?? 0}",
                      icon: Icons.eco,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: "Risk",
                      value: riskLevel.toUpperCase(),
                      icon: Icons.shield,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SectionCard(
          title: "Top Issues",
          child: topIssues.isEmpty
              ? const Text(
                  "No issues detected.",
                  style: TextStyle(color: Colors.black54),
                )
              : Column(
                  children: topIssues.map((e) {
                    final type = (e["type"] ?? "unknown").toString();
                    final count = (e["count"] ?? 0).toString();
                    final avg = (e["avg_conf"] ?? 0.0).toString();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              type,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            "×$count",
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "avg $avg",
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),

        SectionCard(
          title: "Farmer Report",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              if (findings.isNotEmpty) ...[
                const Text(
                  "Key findings",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                ...findings.map((s) => _bullet(s)),
                const SizedBox(height: 10),
              ],
              if (actions.isNotEmpty) ...[
                const Text(
                  "Priority actions",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                ...actions.map((s) => _bullet(s)),
              ],
            ],
          ),
        ),

        SectionCard(
          title: "Frames",
          child: SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: "View all frames",
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FramesScreen(runId: report.runId),
                  ),
                );
              },
            ),
          ),
        ),
      ],
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

  Widget _bullet(String s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.w900)),
          Expanded(child: Text(s)),
        ],
      ),
    );
  }
}
