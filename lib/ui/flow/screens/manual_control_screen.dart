import 'package:flutter/material.dart';

class ManualControlScreen extends StatelessWidget {
  const ManualControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback onPressed, {bool danger = false}) {
      return SizedBox(
        width: 90,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: danger ? Colors.red : null,
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 28),
        ),
      );
    }

    // Later: call backend endpoint or socket emit to control cmd_vel
    void noop() {}

    return Scaffold(
      appBar: AppBar(title: const Text("Manual Control")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hold buttons to move",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            btn(Icons.keyboard_arrow_up, noop),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                btn(Icons.keyboard_arrow_left, noop),
                const SizedBox(width: 12),
                btn(Icons.stop, noop, danger: true),
                const SizedBox(width: 12),
                btn(Icons.keyboard_arrow_right, noop),
              ],
            ),
            const SizedBox(height: 12),
            btn(Icons.keyboard_arrow_down, noop),
          ],
        ),
      ),
    );
  }
}
