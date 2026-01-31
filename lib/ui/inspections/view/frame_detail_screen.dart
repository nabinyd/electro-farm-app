import 'package:electro_farm/config/app_config.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/ui/inspections/providers/frames_provider.dart';
import 'package:electro_farm/ui/inspections/view/widgets/badges.dart';
import 'package:electro_farm/ui/inspections/view/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FrameDetailScreen extends StatelessWidget {
  final String frameId;
  const FrameDetailScreen({super.key, required this.frameId});

  @override
  Widget build(BuildContext context) {
    final loading = context.select((FramesProvider p) => p.loading);
    final error = context.select((FramesProvider p) => p.error);
    final frames = context.select((FramesProvider p) => p.frames);

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        appBar: ElectrofarmAppBar(
          title: "Frame Detail",
          showBackButton: true,
          showLogoutButton: false,
        ),
        body: Center(
          child: Text(error, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    if (frames.isEmpty) {
      return const Scaffold(body: Center(child: Text("No frames loaded.")));
    }

    final frame = frames.firstWhere(
      (e) => e.frameId == frameId,
      orElse: () => frames.first,
    );

    final issues = frame.findings?.issues ?? const [];
    final health = frame.findings?.plantHealth ?? "unknown";
    final img = _toPublicImageUrl(frame.imagePath);

    return Scaffold(
      appBar: ElectrofarmAppBar(
        title: "Frame Detail",
        showBackButton: true,
        showLogoutButton: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: StatusBadge(status: frame.status)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
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
                      child: Image.network(
                        img,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Text("Image failed to load"),
                        ),
                      ),
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
                    children: issues.map<Widget>((iss) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.06),
                          ),
                        ),
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
                                  const SizedBox(height: 4),
                                  Text(
                                    "Confidence: ${(iss.confidence * 100).toStringAsFixed(1)}%",
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
