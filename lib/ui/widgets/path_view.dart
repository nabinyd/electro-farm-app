import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:electro_farm/models/telemetry_model.dart';

class PathView extends StatelessWidget {
  final List<Telemetry> history;
  const PathView({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // Extract points from odom2d if available
    final points = <Offset>[];
    double? lastYaw;

    for (final t in history) {
      final odom = t.odom2d;
      if (odom == null) continue;

      // Model already provides doubles
      points.add(Offset(odom.x, odom.y));
      lastYaw = odom.yaw;
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
                "No odometry data yet.\nStart /odometry/filtered → bridge → backend.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: _PathPainter(points: points, lastYaw: lastYaw),
              ),
            ),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final List<Offset> points;
  final double? lastYaw;
  _PathPainter({required this.points, required this.lastYaw});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // padding so path isn't stuck to border
    const pad = 10.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    final xs = points.map((p) => p.dx).toList();
    final ys = points.map((p) => p.dy).toList();

    final minX = xs.reduce(math.min);
    final maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);

    double nx(double x) {
      final dx = (maxX - minX).abs() < 1e-6 ? 1.0 : (maxX - minX);
      return pad + ((x - minX) / dx) * w;
    }

    double ny(double y) {
      final dy = (maxY - minY).abs() < 1e-6 ? 1.0 : (maxY - minY);
      // invert y for natural map feel
      return pad + (h - ((y - minY) / dy) * h);
    }

    final pathPaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..color = Colors.blueGrey
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final markerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blueGrey;

    // Draw path
    final path = Path()..moveTo(nx(points[0].dx), ny(points[0].dy));
    for (int i = 1; i < points.length; i++) {
      path.lineTo(nx(points[i].dx), ny(points[i].dy));
    }
    canvas.drawPath(path, pathPaint);

    // Draw last point marker
    final last = points.last;
    final lastPt = Offset(nx(last.dx), ny(last.dy));
    canvas.drawCircle(lastPt, 5, markerPaint);

    // Optional: heading arrow using yaw
    if (lastYaw != null) {
      final arrowLen = 16.0;
      // yaw in world frame; since we inverted Y, flip sign for canvas arrow
      final ang = -lastYaw!;
      final tip = Offset(
        lastPt.dx + arrowLen * math.cos(ang),
        lastPt.dy + arrowLen * math.sin(ang),
      );

      final arrowPaint = Paint()
        ..color = Colors.blueGrey
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(lastPt, tip, arrowPaint);

      // arrow head
      final head = 6.0;
      final left = Offset(
        tip.dx - head * math.cos(ang - math.pi / 6),
        tip.dy - head * math.sin(ang - math.pi / 6),
      );
      final right = Offset(
        tip.dx - head * math.cos(ang + math.pi / 6),
        tip.dy - head * math.sin(ang + math.pi / 6),
      );
      canvas.drawLine(tip, left, arrowPaint);
      canvas.drawLine(tip, right, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    if (oldDelegate.points.length != points.length) return true;
    if (points.isEmpty) return false;
    return oldDelegate.points.last != points.last ||
        oldDelegate.lastYaw != lastYaw;
  }
}
