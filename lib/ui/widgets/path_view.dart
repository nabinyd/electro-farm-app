import 'package:flutter/material.dart';
import 'package:electro_farm/models/telemetry_model.dart';

class PathView extends StatelessWidget {
  final List<Telemetry> history;
  const PathView({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // Extract points from odom if available
    final points = <Offset>[];
    for (final t in history) {
      final p = _tryGetXY(t);
      if (p != null) points.add(p);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mini Map Path (x,y)",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          if (points.length < 2)
            Container(
              height: 180,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.03),
              ),
              child: const Text(
                "No odometry data yet.\nSend { odom: { x, y } } from ROS to enable path view.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(painter: _PathPainter(points)),
            ),
        ],
      ),
    );
  }

  /// Returns x,y from Telemetry.odom if available.
  /// Expected backend format:
  /// { "odom": { "x": 1.2, "y": -0.3, "yaw": 1.57 } }
  Offset? _tryGetXY(Telemetry t) {
    final odom = t.odom;
    if (odom == null) return null;

    final x = _toDouble(odom["x"], null);
    final y = _toDouble(odom["y"], null);
    if (x == null || y == null) return null;

    return Offset(x, y);
  }

  double? _toDouble(dynamic v, double? fallback) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }
}

class _PathPainter extends CustomPainter {
  final List<Offset> points;
  _PathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final xs = points.map((p) => p.dx).toList();
    final ys = points.map((p) => p.dy).toList();

    final minX = xs.reduce((a, b) => a < b ? a : b);
    final maxX = xs.reduce((a, b) => a > b ? a : b);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);

    double nx(double x) {
      final dx = (maxX - minX).abs() < 1e-6 ? 1.0 : (maxX - minX);
      return ((x - minX) / dx) * size.width;
    }

    double ny(double y) {
      final dy = (maxY - minY).abs() < 1e-6 ? 1.0 : (maxY - minY);
      return size.height - ((y - minY) / dy) * size.height;
    }

    final pathPaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..color = Colors.blueGrey;

    final markerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blueGrey;

    final path = Path()..moveTo(nx(points[0].dx), ny(points[0].dy));
    for (int i = 1; i < points.length; i++) {
      path.lineTo(nx(points[i].dx), ny(points[i].dy));
    }

    canvas.drawPath(path, pathPaint);

    final last = points.last;
    canvas.drawCircle(Offset(nx(last.dx), ny(last.dy)), 5, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    // Repaint only if points changed
    if (oldDelegate.points.length != points.length) return true;
    if (points.isEmpty) return false;
    return oldDelegate.points.last != points.last;
  }
}
