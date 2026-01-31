import 'package:electro_farm/config/app_config.dart';
import 'package:electro_farm/services/inspection_service.dart';
import 'package:electro_farm/ui/inspections/providers/frames_provider.dart';
import 'package:electro_farm/ui/inspections/view/widgets/badges.dart';
import 'package:electro_farm/ui/inspections/view/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FramesScreen extends StatelessWidget {
  final String runId;
  const FramesScreen({super.key, required this.runId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FramesProvider(api: InspectionApi(), runId: runId)..load(),
      child: _FramesView(runId: runId),
    );
  }
}

class _FramesView extends StatelessWidget {
  final String runId;
  const _FramesView({required this.runId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FramesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Frames",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<FramesProvider>().load(),
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
                ),
              )
            : p.frames.isEmpty
            ? const Center(
                child: Text(
                  "No frames yet",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            : ListView.builder(
                itemCount: p.frames.length,
                itemBuilder: (_, i) {
                  final f = p.frames[i];
                  final health = f.findings?.plantHealth ?? "unknown";
                  final issues = f.findings?.issues.length ?? 0;

                  // If you expose images via /uploads/<filename>
                  final imageUrl = _toPublicImageUrl(f.imagePath);

                  return SectionCard(
                    title: "Frame • ${f.frameId.substring(0, 8)}",
                    trailing: StatusBadge(status: f.status),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(imageUrl, fit: BoxFit.cover),
                            ),
                          )
                        else
                          const Text(
                            "Image preview not configured.\nExpose uploads route to view images.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Health: $health",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              "Issues: $issues",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              "/inspection/frame/$runId/${f.frameId}",
                            ),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text("Open Details"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  String? _toPublicImageUrl(String imagePath) {
    // backend save_path: uploads/<uuid>.jpg
    // You need a Flask route: /uploads/<filename> that serves from UPLOADS_DIR.
    final idx = imagePath.replaceAll("\\", "/").lastIndexOf("/uploads/");
    if (idx != -1) {
      final file = imagePath.substring(idx + "/uploads/".length);
      return "${AppConfig.backendUrl}/uploads/$file";
    }

    // If your imagePath is already like "uploads/xxx.jpg"
    if (imagePath.startsWith("uploads/")) {
      final file = imagePath.substring("uploads/".length);
      return "${AppConfig.backendUrl}/uploads/$file";
    }

    return null;
  }
}
