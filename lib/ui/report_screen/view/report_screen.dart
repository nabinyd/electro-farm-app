import 'package:electro_farm/core/utils/responsive_padding.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:flutter/material.dart';
import '../../flow/app_flow.dart';

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
      appBar: ElectrofarmAppBar(
        title: "Task Report",
        showBackButton: false,
        showLogoutButton: false,
      ),
      body: Padding(
        padding: AppPadding.allMD,
        child: Column(
          children: [
            Container(
              padding: AppPadding.allMD,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.onBackground),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
              child: CustomButton(text: "START NEW TASK", onPressed: onNewTask),
            ),
            SizedBox(height: 18),
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
            child: Text(
              k,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
