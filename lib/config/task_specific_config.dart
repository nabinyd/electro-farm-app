import 'package:electro_farm/ui/home_screen/home_screen.dart';

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

  FarmTask.spray: TaskMeta(
    mode: "Autonomous Spraying",
    safety: "Auto cut-off near obstacles",
    expectedTime: "≈ 15–30 min",
    pattern: "Z-pattern spray",
  ),
  FarmTask.inspect: TaskMeta(
    mode: "Crop Inspection",
    safety: "Low-speed safe navigation",
    expectedTime: "≈ 10–20 min",
    pattern: "Full field scan",
  ),
};
