import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/models/inspection_models.dart';
import 'package:electro_farm/ui/inspections/providers/frames_provider.dart';
import 'package:electro_farm/ui/inspections/view/frame_detail_screen.dart';
import 'package:electro_farm/ui/inspections/view/widgets/badges.dart';
import 'package:electro_farm/ui/inspections/view/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FramesScreen extends StatefulWidget {
  final String runId;
  const FramesScreen({super.key, required this.runId});

  @override
  State<FramesScreen> createState() => _FramesScreenState();
}

class _FramesScreenState extends State<FramesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FramesProvider>().load(widget.runId);
    });
  }

  @override
  void didUpdateWidget(covariant FramesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.runId != widget.runId) {
      context.read<FramesProvider>().load(widget.runId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElectrofarmAppBar(
        title: "Frames",
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: () => context.read<FramesProvider>().load(widget.runId),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: const _FramesBody(),
    );
  }
}

class _FramesBody extends StatelessWidget {
  const _FramesBody();

  @override
  Widget build(BuildContext context) {
    final loading = context.select((FramesProvider p) => p.loading);
    final error = context.select((FramesProvider p) => p.error);
    final frames = context.select((FramesProvider p) => p.frames);

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return _ErrorState(message: error);
    }

    if (frames.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: frames.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final f = frames[i];
        return _FrameCard(frame: f, index: i);
      },
    );
  }
}

class _FrameCard extends StatelessWidget {
  final InspectionFrame frame;
  final int index;
  const _FrameCard({required this.frame, required this.index});

  @override
  Widget build(BuildContext context) {
    final health = frame.findings?.plantHealth ?? "unknown";
    final issuesCount = frame.findings?.issues.length ?? 0;

    return SectionCard(
      title: "Frame #${index + 1} • ${frame.frameId.substring(0, 8)}",
      trailing: StatusBadge(status: frame.status),
      child: Column(
        children: [
          Row(
            children: [
              _MiniChip(icon: Icons.eco, label: "Health: $health"),
              const SizedBox(width: 8),
              _MiniChip(icon: Icons.bug_report, label: "Issues: $issuesCount"),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FrameDetailScreen(frameId: frame.frameId),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text("Open details"),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.photo_library_outlined, size: 40, color: Colors.black45),
            SizedBox(height: 10),
            Text(
              "No frames yet",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 6),
            Text(
              "Frames will appear as the inspection processes images.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 10),
            const Text(
              "Failed to load frames",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                // We need runId here; easiest: pop and refresh from previous screen,
                // OR wrap this widget to pass runId. If you want, I’ll adjust.
                Navigator.of(context).maybePop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Go back"),
            ),
          ],
        ),
      ),
    );
  }
}
