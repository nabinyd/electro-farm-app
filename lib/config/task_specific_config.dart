import 'package:electro_farm/ui/flow/app_flow.dart';

class TaskMeta {
  final String mode;
  final String safety;
  final String expectedTime;
  final String pattern;

  const TaskMeta({
    required this.mode,
    required this.safety,
    required this.expectedTime,
    required this.pattern,
  });
}

const Map<FarmTask, TaskMeta> taskMetaMap = {
  FarmTask.seed: TaskMeta(
    mode: "Autonomous Seeding",
    safety: "Stops on obstacle detection",
    expectedTime: "≈ 20–40 min",
    pattern: "Row-based seeding",
  ),
  FarmTask.spray: TaskMeta(
    mode: "Autonomous Spraying",
    safety: "Auto cut-off near obstacles",
    expectedTime: "≈ 15–30 min",
    pattern: "Z-pattern spray",
  ),
  FarmTask.weed: TaskMeta(
    mode: "Selective Weeding",
    safety: "Vision-based obstacle avoidance",
    expectedTime: "≈ 25–45 min",
    pattern: "Row scanning",
  ),
  FarmTask.inspect: TaskMeta(
    mode: "Crop Inspection",
    safety: "Low-speed safe navigation",
    expectedTime: "≈ 10–20 min",
    pattern: "Full field scan",
  ),
};
