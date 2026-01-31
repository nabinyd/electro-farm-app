import 'package:electro_farm/config/task_specific_config.dart';
import 'package:electro_farm/core/utils/button_types.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/custom_component/custom_button.dart';
import 'package:electro_farm/ui/widgets/premium_widget.dart';
import 'package:flutter/material.dart';
import '../../flow/app_flow.dart';

class ConfirmTaskScreen extends StatelessWidget {
  final FarmTask task;
  final VoidCallback onStart;

  const ConfirmTaskScreen({
    super.key,
    required this.task,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final meta = taskMetaMap[task]!;
    return Scaffold(
      appBar: ElectrofarmAppBar(title: "Confirm Task"),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            PremiumCard(
              title: taskLabel(task),
              child: Column(
                children: [
                  _kv("Mode", meta.mode),
                  _kv("Safety", meta.safety),
                  _kv("Expected Time", meta.expectedTime),
                  _kv("Pattern", meta.pattern),
                ],
              ),
            ),

            const SizedBox(height: 12),
            PremiumCard(
              title: "Before Starting",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "• Ensure robot is on flat ground.",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "• Keep phone nearby for emergency stop.",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "• Check spraying tank (if spraying).",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Back",
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    type: ButtonType.outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: "Start",
                    icon: Icon(Icons.play_arrow),
                    onPressed: onStart,
                    type: ButtonType.primary,
                    isLoading: false,
                    isDisabled: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(k, style: const TextStyle(color: AppColors.primary)),
          ),
          Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
