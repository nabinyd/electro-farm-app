import 'package:electro_farm/core/utils/responsive_padding.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/ui/flow/app_flow.dart';
import 'package:flutter/material.dart';

class TaskSelectionScreen extends StatelessWidget {
  final void Function(FarmTask task) onSelect;
  const TaskSelectionScreen({super.key, required this.onSelect});

  String _desc(FarmTask t) {
    switch (t) {
      case FarmTask.seed:
        return "Robot marks rows and assists seeding process.";
      case FarmTask.spray:
        return "Autonomous spraying along rows with obstacle safety.";
      case FarmTask.weed:
        return "Navigate rows for weed removal/spot detection.";
      case FarmTask.inspect:
        return "Capture crop images + health monitoring + map points.";
    }
  }

  String _tag(FarmTask t) {
    switch (t) {
      case FarmTask.seed:
        return "Field Setup";
      case FarmTask.spray:
        return "Most Used";
      case FarmTask.weed:
        return "Advanced";
      case FarmTask.inspect:
        return "AI Ready";
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = FarmTask.values;

    return Scaffold(
      appBar: ElectrofarmAppBar(title: "Select Task"),
      body: Padding(
        padding: AppPadding.allMD,
        child: ListView(
          children: [
            const Text(
              "Choose what you want the robot to do",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              "You can review details before starting.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            ...tasks.map(
              (t) => _TaskCard(
                task: t,
                tag: _tag(t),
                desc: _desc(t),
                onTap: () => onSelect(t),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final FarmTask task;
  final String tag;
  final String desc;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.tag,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: AppPadding.allMD,
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.04),
                  border: Border.all(color: Colors.black12),
                ),
                child: Icon(taskIcon(task)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskLabel(task),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.primary
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                        color: Colors.black.withValues(alpha: .03),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
