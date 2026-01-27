import 'package:flutter/material.dart';
import '../app_flow.dart';

class ReportScreen extends StatelessWidget {
  final FarmTask task;
  final int totalRows;
  final int timeTakenMin;
  final int batteryUsedPercent;
  final int laborSavedHours;
  final VoidCallback onNewTask;

  const ReportScreen({
    super.key,
    required this.task,
    required this.totalRows,
    required this.timeTakenMin,
    required this.batteryUsedPercent,
    required this.laborSavedHours,
    required this.onNewTask,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report")),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Work Completed: ${taskLabel(task)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _Stat("Time Taken", "$timeTakenMin min"),
            _Stat("Rows Completed", "$totalRows"),
            _Stat("Battery Used", "$batteryUsedPercent%"),
            _Stat("Estimated Labor Saved", "$laborSavedHours hours"),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNewTask,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text("START NEW TASK"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String k;
  final String v;
  const _Stat(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
