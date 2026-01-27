import 'package:flutter/material.dart';
import '../../services/socket_service.dart';

class StatusBanner extends StatelessWidget {
  final SocketStatus status;
  final int batteryPercent;
  final String signalText;

  const StatusBanner({
    super.key,
    required this.status,
    required this.batteryPercent,
    required this.signalText,
  });

  (String, Color, IconData) _map(SocketStatus s) {
    switch (s) {
      case SocketStatus.connected:
        return ("Robot Ready", Colors.green, Icons.check_circle);
      case SocketStatus.connecting:
        return ("Connecting", Colors.orange, Icons.sync);
      case SocketStatus.reconnecting:
        return ("Reconnecting", Colors.deepOrange, Icons.wifi_off);
      case SocketStatus.error:
        return ("Needs Attention", Colors.red, Icons.error);
      default:
        return ("Disconnected", Colors.grey, Icons.link_off);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (text, color, icon) = _map(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
        color: color.withOpacity(0.08),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w900, color: color),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "$batteryPercent% 🔋",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          Text(
            "$signalText 📶",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
