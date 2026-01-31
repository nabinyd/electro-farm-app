import 'package:electro_farm/services/socket_service.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final SocketStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color bg;

    switch (status) {
      case SocketStatus.connected:
        text = "CONNECTED";
        bg = Colors.green;
        break;
      case SocketStatus.connecting:
        text = "CONNECTING";
        bg = Colors.orange;
        break;
      case SocketStatus.reconnecting:
        text = "RECONNECTING";
        bg = Colors.yellow;
        break;
      case SocketStatus.error:
        text = "ERROR";
        bg = Colors.red;
        break;
      default:
        text = "DISCONNECTED";
        bg = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.15),
        border: Border.all(color: bg.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: bg, fontWeight: FontWeight.w700),
      ),
    );
  }
}
