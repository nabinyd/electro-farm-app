import 'dart:math' as math;

import 'package:electro_farm/providers/esp_camera_provider.dart';
import 'package:electro_farm/providers/vision_processor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EspCameraView extends StatelessWidget {
  const EspCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<EspCameraProvider, VisionProcessorProvider>(
      builder: (context, camera, vision, _) {
        final frame = camera.latestFrameBytes;

        if (frame == null) {
          return const Center(child: Text("No camera frame"));
        }

        return Stack(
          children: [
            /// 📷 Camera Image
            Positioned.fill(
              child: Transform.rotate(
                angle: math.pi, // 180 degrees
                child: Image.memory(
                  frame,
                  gaplessPlayback: true,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 🧠 Bounding Boxes Overlay (optional but ready)
            Positioned.fill(
              child: CustomPaint(painter: _BoundingBoxPainter(vision.issues)),
            ),

            /// 📊 Bottom Info Panel
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _VisionInfoPanel(vision: vision),
            ),
          ],
        );
      },
    );
  }
}

class _VisionInfoPanel extends StatelessWidget {
  final VisionProcessorProvider vision;

  const _VisionInfoPanel({required this.vision});

  Color _getHealthColor() {
    switch (vision.plantHealth) {
      case "healthy":
        return Colors.green;
      case "stressed":
        return Colors.orange;
      case "error":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🌿 Health + Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.eco, color: _getHealthColor()),
                  const SizedBox(width: 6),
                  Text(
                    vision.plantHealth.toUpperCase(),
                    style: TextStyle(
                      color: _getHealthColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "Detections: ${vision.totalDetections}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// 🏷️ Tags
          if (vision.recommendationTags.isNotEmpty)
            Wrap(
              spacing: 6,
              children: vision.recommendationTags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.white10,
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                  )
                  .toList(),
            ),

          const SizedBox(height: 8),

          /// ⚠️ Issues List
          if (vision.issues.isNotEmpty)
            Column(
              children: vision.issues.map((issue) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      issue["type"],
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "${issue["confidence"]} (${issue["severity"]})",
                      style: TextStyle(
                        color: _severityColor(issue["severity"]),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.yellow;
      default:
        return Colors.white;
    }
  }
}

class _BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> issues;

  _BoundingBoxPainter(this.issues);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final issue in issues) {
      final bbox = issue["bbox"];
      if (bbox == null || bbox.length != 4) continue;

      final severity = issue["severity"];

      paint.color = _getColor(severity);

      // YOLO gives absolute pixels → need scaling later if mismatch
      final rect = Rect.fromLTRB(
        bbox[0].toDouble(),
        bbox[1].toDouble(),
        bbox[2].toDouble(),
        bbox[3].toDouble(),
      );

      canvas.drawRect(rect, paint);
    }
  }

  Color _getColor(String severity) {
    switch (severity) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
