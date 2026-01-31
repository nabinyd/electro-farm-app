import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color _bg(BuildContext c) {
    switch (status) {
      case "done":
        return Colors.green.withOpacity(.12);
      case "failed":
        return Colors.red.withOpacity(.12);
      case "processing":
        return Colors.orange.withOpacity(.12);
      default:
        return Colors.grey.withOpacity(.12);
    }
  }

  Color _fg(BuildContext c) {
    switch (status) {
      case "done":
        return Colors.green.shade800;
      case "failed":
        return Colors.red.shade800;
      case "processing":
        return Colors.orange.shade900;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bg(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: _fg(context),
          fontSize: 12,
        ),
      ),
    );
  }
}

class SeverityChip extends StatelessWidget {
  final String severity; // low|medium|high
  const SeverityChip({super.key, required this.severity});

  Color _fg() {
    switch (severity) {
      case "high":
        return Colors.red.shade800;
      case "medium":
        return Colors.orange.shade900;
      default:
        return Colors.green.shade800;
    }
  }

  Color _bg() {
    switch (severity) {
      case "high":
        return Colors.red.withOpacity(.12);
      case "medium":
        return Colors.orange.withOpacity(.12);
      default:
        return Colors.green.withOpacity(.12);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: _fg(),
        ),
      ),
    );
  }
}
