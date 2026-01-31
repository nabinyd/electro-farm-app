import 'dart:async';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:electro_farm/providers/telemetry_provider.dart';
import 'package:electro_farm/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManualControlScreen extends StatefulWidget {
  final String robotId;
  const ManualControlScreen({super.key, this.robotId = "agribot-01"});

  @override
  State<ManualControlScreen> createState() => _ManualControlScreenState();
}

class _ManualControlScreenState extends State<ManualControlScreen> {
  // joystick normalized output: [-1..1]
  double _joyX = 0.0; // turn
  double _joyY = 0.0; // forward

  // limits (tune as needed)
  double _maxVx = 0.5; // m/s
  double _maxWz = 1.0; // rad/s

  // send loop (smooth, throttled)
  Timer? _sendTimer;
  bool _sending = false;

  // UI: show command values
  double _cmdVx = 0.0;
  double _cmdWz = 0.0;

  @override
  void initState() {
    super.initState();
    // Start a periodic send loop at 15 Hz
    _sendTimer = Timer.periodic(const Duration(milliseconds: 66), (_) {
      if (!_sending) return;
      _emitCmd();
    });
  }

  @override
  void dispose() {
    // safety stop on exit
    _sendStop();
    _sendTimer?.cancel();
    super.dispose();
  }

  void _emitCmd() {
    final socket = context.read<TelemetryProvider>().socketService;

    // Convert joystick -> velocities
    // Y forward is negative in screen coordinates, we already map to forward positive.
    final vx = _maxVx * _joyY; // forward/back
    final wz = _maxWz * _joyX; // left/right

    setState(() {
      _cmdVx = vx;
      _cmdWz = wz;
    });

    socket.sendCmdVel(robotId: widget.robotId, vx: vx, wz: wz);
  }

  void _sendStop() {
    final socket = context.read<TelemetryProvider>().socketService;
    setState(() {
      _cmdVx = 0;
      _cmdWz = 0;
    });
    socket.sendCmdVel(robotId: widget.robotId, vx: 0, wz: 0);
  }

  void _onJoyChanged(Offset v) {
    // v is [-1..1] x,y
    setState(() {
      _joyX = v.dx.clamp(-1.0, 1.0);
      _joyY = v.dy.clamp(-1.0, 1.0);
    });
  }

  void _onJoyStart() {
    setState(() => _sending = true);
  }

  void _onJoyEnd() {
    setState(() {
      _sending = false;
      _joyX = 0;
      _joyY = 0;
    });
    // immediate stop
    _sendStop();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<TelemetryProvider>().status;
    final connected = status == SocketStatus.connected;

    return Scaffold(
      appBar: ElectrofarmAppBar(title: "Manual Control"),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _TopStatusCard(
              robotId: widget.robotId,
              connected: connected,
              cmdVx: _cmdVx,
              cmdWz: _cmdWz,
              maxVx: _maxVx,
              maxWz: _maxWz,
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _JoystickCard(
                      enabled: connected,
                      onStart: _onJoyStart,
                      onChanged: _onJoyChanged,
                      onEnd: _onJoyEnd,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _ControlsCard(
                      enabled: connected,
                      maxVx: _maxVx,
                      maxWz: _maxWz,
                      onMaxVxChanged: (v) => setState(() => _maxVx = v),
                      onMaxWzChanged: (v) => setState(() => _maxWz = v),
                      onStop: () {
                        setState(() {
                          _sending = false;
                          _joyX = 0;
                          _joyY = 0;
                        });
                        _sendStop();
                      },
                      onNudgeForward: () {
                        // quick tap forward
                        context
                            .read<TelemetryProvider>()
                            .socketService
                            .sendCmdVel(
                              robotId: widget.robotId,
                              vx: 0.15,
                              wz: 0.0,
                            );
                      },
                      onNudgeLeft: () {
                        context
                            .read<TelemetryProvider>()
                            .socketService
                            .sendCmdVel(
                              robotId: widget.robotId,
                              vx: 0.0,
                              wz: 0.3,
                            );
                      },
                      onNudgeRight: () {
                        context
                            .read<TelemetryProvider>()
                            .socketService
                            .sendCmdVel(
                              robotId: widget.robotId,
                              vx: 0.0,
                              wz: -0.3,
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- UI widgets ----------

class _TopStatusCard extends StatelessWidget {
  final String robotId;
  final bool connected;
  final double cmdVx;
  final double cmdWz;
  final double maxVx;
  final double maxWz;

  const _TopStatusCard({
    required this.robotId,
    required this.connected,
    required this.cmdVx,
    required this.cmdWz,
    required this.maxVx,
    required this.maxWz,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = connected ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: chipColor.withOpacity(0.15),
            child: Icon(
              connected ? Icons.link : Icons.link_off,
              color: chipColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Robot: $robotId",
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  connected ? "Connected • Manual mode" : "Not connected",
                  style: TextStyle(color: Colors.black.withOpacity(0.55)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "vx: ${cmdVx.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                "wz: ${cmdWz.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                "limits vx≤${maxVx.toStringAsFixed(2)}, wz≤${maxWz.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JoystickCard extends StatelessWidget {
  final bool enabled;
  final VoidCallback onStart;
  final ValueChanged<Offset> onChanged;
  final VoidCallback onEnd;

  const _JoystickCard({
    required this.enabled,
    required this.onStart,
    required this.onChanged,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Joystick", style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            enabled ? "Hold and drag to drive" : "Connect first to enable",
            style: TextStyle(color: Colors.black.withOpacity(0.55)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Opacity(
                opacity: enabled ? 1.0 : 0.5,
                child: _Joystick(
                  enabled: enabled,
                  onStart: onStart,
                  onChanged: onChanged,
                  onEnd: onEnd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple joystick returning normalized vector:
/// dx = turn (-1..1), dy = forward (-1..1)
class _Joystick extends StatefulWidget {
  final bool enabled;
  final VoidCallback onStart;
  final ValueChanged<Offset> onChanged;
  final VoidCallback onEnd;

  const _Joystick({
    required this.enabled,
    required this.onStart,
    required this.onChanged,
    required this.onEnd,
  });

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  Offset _knob = Offset.zero; // pixels from center
  final double _radius = 90;

  Offset _normalize(Offset p) {
    final dx = (p.dx / _radius).clamp(-1.0, 1.0);
    final dy = (-p.dy / _radius).clamp(-1.0, 1.0); // invert y so up is +forward
    return Offset(dx, dy);
  }

  Offset _clampToCircle(Offset p) {
    final d = p.distance;
    if (d <= _radius) return p;
    final k = _radius / d;
    return Offset(p.dx * k, p.dy * k);
  }

  void _handleStart() {
    if (!widget.enabled) return;
    widget.onStart();
  }

  void _handleUpdate(Offset localPos, Size size) {
    if (!widget.enabled) return;

    final center = Offset(size.width / 2, size.height / 2);
    final delta = localPos - center;
    final clamped = _clampToCircle(delta);

    setState(() => _knob = clamped);
    widget.onChanged(_normalize(clamped));
  }

  void _handleEnd() {
    if (!widget.enabled) return;

    setState(() => _knob = Offset.zero);
    widget.onChanged(const Offset(0, 0));
    widget.onEnd();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final size = Size(_radius * 2, _radius * 2);

        return GestureDetector(
          onPanStart: (_) => _handleStart(),
          onPanUpdate: (d) => _handleUpdate(d.localPosition, size),
          onPanEnd: (_) => _handleEnd(),
          onPanCancel: _handleEnd,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(
              painter: _JoystickPainter(knob: _knob, radius: _radius),
            ),
          ),
        );
      },
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final Offset knob;
  final double radius;
  _JoystickPainter({required this.knob, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final basePaint = Paint()..color = Colors.black.withOpacity(0.06);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black.withOpacity(0.12);

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawCircle(center, radius, ringPaint);

    // crosshair
    final cross = Paint()
      ..strokeWidth = 1
      ..color = Colors.black.withOpacity(0.15);
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      cross,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      cross,
    );

    // knob
    final knobPaint = Paint()..color = const Color(0xFF0A264D).withOpacity(0.9);
    canvas.drawCircle(center + knob, 22, knobPaint);

    final knobGlow = Paint()..color = const Color(0xFF0A264D).withOpacity(0.12);
    canvas.drawCircle(center + knob, 40, knobGlow);
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) =>
      oldDelegate.knob != knob || oldDelegate.radius != radius;
}

class _ControlsCard extends StatelessWidget {
  final bool enabled;
  final double maxVx;
  final double maxWz;
  final ValueChanged<double> onMaxVxChanged;
  final ValueChanged<double> onMaxWzChanged;

  final VoidCallback onStop;
  final VoidCallback onNudgeForward;
  final VoidCallback onNudgeLeft;
  final VoidCallback onNudgeRight;

  const _ControlsCard({
    required this.enabled,
    required this.maxVx,
    required this.maxWz,
    required this.onMaxVxChanged,
    required this.onMaxWzChanged,
    required this.onStop,
    required this.onNudgeForward,
    required this.onNudgeLeft,
    required this.onNudgeRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Controls", style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),

          Text(
            "Max speed (vx)",
            style: TextStyle(color: Colors.black.withOpacity(0.65)),
          ),
          Slider(
            value: maxVx,
            min: 0.1,
            max: 1.0,
            divisions: 18,
            onChanged: enabled ? onMaxVxChanged : null,
          ),
          Text(
            "Max turn (wz)",
            style: TextStyle(color: Colors.black.withOpacity(0.65)),
          ),
          Slider(
            value: maxWz,
            min: 0.2,
            max: 2.0,
            divisions: 18,
            onChanged: enabled ? onMaxWzChanged : null,
          ),

          const SizedBox(height: 10),

          // quick nudges
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: enabled ? onNudgeLeft : null,
                  child: const Text("Left"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: enabled ? onNudgeForward : null,
                  child: const Text("Forward"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: enabled ? onNudgeRight : null,
                  child: const Text("Right"),
                ),
              ),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: "STOP",
              onPressed: onStop,
              isDisabled: !enabled,
            ),
          ),
        ],
      ),
    );
  }
}
