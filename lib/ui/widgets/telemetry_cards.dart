import 'package:electro_farm/models/telemetry_model.dart';
import 'package:flutter/material.dart';

class TelemetryCards extends StatelessWidget {
  const TelemetryCards({super.key, required this.t});
  final Telemetry t;

  @override
  Widget build(BuildContext context) {
    final imu = t.imu;

    return Column(
      children: [
        _Card(
          title: "Robot",
          children: [
            _RowItem(label: "ID", value: t.robotId),
            _RowItem(label: "Time", value: t.ts.toLocal().toString()),
          ],
        ),
        const SizedBox(height: 12),

        if (imu == null)
          _Card(
            title: "IMU",
            children: const [Text("No IMU data in telemetry payload.")],
          )
        else
          _Card(
            title: "IMU (${imu.frameId})",
            children: [
              _RowItem(
                label: "Orientation",
                value: imu.orientationValid ? "Valid" : "Not provided",
              ),
              const SizedBox(height: 8),

              Text(
                "Angular Velocity (rad/s)",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              _RowItem(label: "wx", value: imu.angVel.x.toStringAsFixed(3)),
              _RowItem(label: "wy", value: imu.angVel.y.toStringAsFixed(3)),
              _RowItem(label: "wz", value: imu.angVel.z.toStringAsFixed(3)),

              const SizedBox(height: 10),
              Text(
                "Linear Acceleration (m/s²)",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              _RowItem(label: "ax", value: imu.linAcc.x.toStringAsFixed(3)),
              _RowItem(label: "ay", value: imu.linAcc.y.toStringAsFixed(3)),
              _RowItem(label: "az", value: imu.linAcc.z.toStringAsFixed(3)),

              const SizedBox(height: 10),
              _RowItem(
                label: "Accel Magnitude",
                value: imu.linAcc.magnitude().toStringAsFixed(3),
              ),
            ],
          ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
