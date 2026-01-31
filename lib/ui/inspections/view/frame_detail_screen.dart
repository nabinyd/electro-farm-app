import 'package:electro_farm/config/app_config.dart';
import 'package:electro_farm/services/inspection_service.dart';
import 'package:electro_farm/ui/inspections/providers/frames_provider.dart';
import 'package:electro_farm/ui/inspections/view/widgets/badges.dart';
import 'package:electro_farm/ui/inspections/view/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FrameDetailScreen extends StatelessWidget {
  final String runId;
  final String frameId;
  const FrameDetailScreen({
    super.key,
    required this.runId,
    required this.frameId,
  });

  @override
  Widget build(BuildContext context) {
    // reuse FramesProvider and pick one frame
    return ChangeNotifierProvider(
      create: (_) => FramesProvider(api: InspectionApi(), runId: runId)..load(),
      child: _View(frameId: frameId),
    );
  }
}

class _View extends StatelessWidget {
  final String frameId;
  const _View({required this.frameId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FramesProvider>();
    if (p.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (p.error != null) {
      return Scaffold(
        body: Center(
          child: Text(p.error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final frame = p.frames.firstWhere(
      (e) => e.frameId == frameId,
      orElse: () => p.frames.first,
    );

    final img = _toPublicImageUrl(frame.imagePath);
    final issues = frame.findings?.issues ?? const [];
    final health = frame.findings?.plantHealth ?? "unknown";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Frame Details",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: StatusBadge(status: frame.status)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView(
          children: [
            SectionCard(
              title: "Preview",
              child: img == null
                  ? const Text(
                      "Image preview not configured.",
                      style: TextStyle(color: Colors.black54),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(img, fit: BoxFit.cover),
                      ),
                    ),
            ),
            SectionCard(
              title: "Health",
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      health,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    "Issues: ${issues.length}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            SectionCard(
              title: "Issues",
              child: issues.isEmpty
                  ? const Text(
                      "No issues detected.",
                      style: TextStyle(color: Colors.black54),
                    )
                  : Column(
                      children: issues.map((iss) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      iss.type,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Confidence: ${iss.confidence.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    if (iss.bbox != null)
                                      Text(
                                        "BBox: ${iss.bbox!.map((e) => e.toStringAsFixed(0)).join(", ")}",
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SeverityChip(severity: iss.severity),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String? _toPublicImageUrl(String imagePath) {
    if (imagePath.startsWith("uploads/")) {
      final file = imagePath.substring("uploads/".length);
      return "${AppConfig.backendUrl}/uploads/$file";
    }
    final p = imagePath.replaceAll("\\", "/");
    final idx = p.lastIndexOf("/uploads/");
    if (idx != -1) {
      final file = p.substring(idx + "/uploads/".length);
      return "${AppConfig.backendUrl}/uploads/$file";
    }
    return null;
  }
}
