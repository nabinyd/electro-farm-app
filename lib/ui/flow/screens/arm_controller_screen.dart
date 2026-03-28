import 'dart:async';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:electro_farm/providers/telemetry_provider.dart';
import 'package:electro_farm/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArmControlScreen extends StatefulWidget {
  final String robotId;

  const ArmControlScreen({super.key, this.robotId = "agribot-01"});

  @override
  State<ArmControlScreen> createState() => _ArmControlScreenState();
}

class _ArmControlScreenState extends State<ArmControlScreen> {
  late SocketService _socket;

  // Current angles (UI state)
  final Map<String, double> _angles = {
    'A': 90.0,
    'B': 90.0,
    'C': 90.0,
    'D': 90.0,
    'E': 90.0,
  };

  Map<String, double> get angles => _angles;

  // Rate limiting
  Timer? _sendTimer;
  Map<String, double>? _pendingUpdate;
  bool _isSending = false;

  // Throttle settings
  static const _sendInterval = Duration(
    milliseconds: 150,
  ); // Reduced from 50ms to 150ms
  static const _maxQueueSize = 10;

  @override
  void initState() {
    super.initState();
    _startSendTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _socket = context.read<TelemetryProvider>().socketService;
  }

  @override
  void dispose() {
    _sendTimer?.cancel();
    _isSending = false;
    super.dispose();
  }

  void _startSendTimer() {
    _sendTimer?.cancel();
    _sendTimer = Timer.periodic(_sendInterval, (timer) {
      if (_pendingUpdate != null && mounted && !_isSending) {
        _sendPendingUpdate();
      }
    });
  }

  Future<void> _sendPendingUpdate() async {
    if (_pendingUpdate == null) return;

    _isSending = true;
    final update = Map<String, double>.from(_pendingUpdate!);
    _pendingUpdate = null;

    try {
      await _sendArmCommand(update);
    } catch (e) {
      debugPrint("Error sending arm command: $e");
      // Re-queue if it's a single joint update
      if (update.length == 1 && _pendingUpdate == null) {
        _pendingUpdate = update;
      }
    } finally {
      _isSending = false;
    }
  }

  Future<void> _sendArmCommand(Map<String, double> angles) async {
    if (!mounted) return;

    final status = _socket.status;
    if (status != SocketStatus.connected) {
      debugPrint("Not connected, skipping arm command");
      return;
    }

    // Single joint
    if (angles.length == 1) {
      final motor = angles.keys.first;
      final angle = angles.values.first;
      _socket.sendArmCommand(
        robotId: widget.robotId,
        motor: motor,
        angle: angle,
      );
    }
    // Multiple joints
    else {
      final commands = angles.entries
          .map((entry) => {"motor": entry.key, "angle": entry.value})
          .toList();

      _socket.sendArmCommand(robotId: widget.robotId, commands: commands);
    }
  }

  // 🔹 Update single joint with rate limiting
  void updateJoint({required String motor, required double angle}) {
    final clamped = angle.clamp(0, 180).toDouble();

    setState(() {
      _angles[motor] = clamped;
    });

    // Queue the update
    if (_pendingUpdate == null) {
      _pendingUpdate = {motor: clamped};
    } else {
      // Merge with pending update
      _pendingUpdate![motor] = clamped;

      // Limit queue size to prevent memory issues
      if (_pendingUpdate!.length > _maxQueueSize) {
        _pendingUpdate = {motor: clamped};
      }
    }
  }

  // 🔹 Update multiple joints
  void updateMultiple(Map<String, double> newAngles) {
    final commands = <Map<String, dynamic>>[];
    final updatedAngles = <String, double>{};

    setState(() {
      newAngles.forEach((motor, angle) {
        final clamped = angle.clamp(0, 180).toDouble();
        _angles[motor] = clamped;
        updatedAngles[motor] = clamped;
        commands.add({"motor": motor, "angle": clamped});
      });
    });

    // Send immediately for batch updates
    _sendArmCommand(updatedAngles);
  }

  // 🔹 Reset to default position
  void reset() {
    const defaultAngles = {
      'A': 90.0,
      'B': 90.0,
      'C': 90.0,
      'D': 90.0,
      'E': 90.0,
    };

    updateMultiple(defaultAngles);
  }

  // 🔹 Preset positions
  void setPreset(String preset) {
    if (preset == "pick") {
      updateMultiple({'A': 90.0, 'B': 120.0, 'C': 60.0, 'D': 90.0, 'E': 40.0});
    } else if (preset == "place") {
      updateMultiple({
        'A': 100.0,
        'B': 80.0,
        'C': 120.0,
        'D': 90.0,
        'E': 120.0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _socket.status;
    final connected = status == SocketStatus.connected;

    return Scaffold(
      appBar: ElectrofarmAppBar(title: "Arm Control"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _TopStatusCard(
                robotId: widget.robotId,
                connected: connected,
                angles: _angles,
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Joint Controls",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Joint A
                    _JointSlider(
                      label: "Joint A",
                      value: _angles['A']!,
                      onChanged: connected
                          ? (value) => updateJoint(motor: 'A', angle: value)
                          : null,
                      enabled: connected,
                    ),
                    const SizedBox(height: 8),

                    // Joint B
                    _JointSlider(
                      label: "Joint B",
                      value: _angles['B']!,
                      onChanged: connected
                          ? (value) => updateJoint(motor: 'B', angle: value)
                          : null,
                      enabled: connected,
                    ),
                    const SizedBox(height: 8),

                    // Joint C
                    _JointSlider(
                      label: "Joint C",
                      value: _angles['C']!,
                      onChanged: connected
                          ? (value) => updateJoint(motor: 'C', angle: value)
                          : null,
                      enabled: connected,
                    ),
                    const SizedBox(height: 8),

                    // Joint D
                    _JointSlider(
                      label: "Joint D",
                      value: _angles['D']!,
                      onChanged: connected
                          ? (value) => updateJoint(motor: 'D', angle: value)
                          : null,
                      enabled: connected,
                    ),
                    const SizedBox(height: 8),

                    // Joint E
                    _JointSlider(
                      label: "Joint E",
                      value: _angles['E']!,
                      onChanged: connected
                          ? (value) => updateJoint(motor: 'E', angle: value)
                          : null,
                      enabled: connected,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Preset buttons
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Preset Positions",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: connected
                                ? () => setPreset("pick")
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Pick Position"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: connected
                                ? () => setPreset("place")
                                : null,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Place Position"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: "Reset to Default",
                        onPressed: reset,
                        isDisabled: !connected,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status card showing connection info and current angles
class _TopStatusCard extends StatelessWidget {
  final String robotId;
  final bool connected;
  final Map<String, double> angles;

  const _TopStatusCard({
    required this.robotId,
    required this.connected,
    required this.angles,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = connected ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: chipColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  connected ? Icons.sensors : Icons.portable_wifi_off,
                  color: chipColor,
                ),
              ),

              const SizedBox(width: 14),

              // Robot Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AgriBot Arm • $robotId",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Status Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: chipColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        connected ? "Connected • Manual" : "Disconnected",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: chipColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Angle summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: angles.entries.map((entry) {
                return _AngleIndicator(label: entry.key, angle: entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual angle indicator
class _AngleIndicator extends StatelessWidget {
  final String label;
  final double angle;

  const _AngleIndicator({required this.label, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            angle.toInt().toString(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ),
        const Text("°", style: TextStyle(fontSize: 10)),
      ],
    );
  }
}

/// Joint slider widget
class _JointSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double>? onChanged;
  final bool enabled;

  const _JointSlider({
    required this.label,
    required this.value,
    this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${value.toInt()}°",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Slider(
          value: value,
          min: 0,
          max: 180,
          divisions: 180,
          onChanged: onChanged,
          activeColor: enabled ? const Color(0xFF0A264D) : Colors.grey,
        ),
      ],
    );
  }
}
