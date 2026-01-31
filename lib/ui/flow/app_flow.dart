import 'package:electro_farm/ui/task_selection/view/task_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/telemetry_provider.dart';

import '../home_screen/view/home_screen.dart';
import '../task_selection/view/confirm_task_screen.dart';
import 'screens/working_screen.dart';
import '../home_screen/view/manual_control_screen.dart';
import '../home_screen/view/dashboard_screen.dart';

enum FarmTask { seed, spray, weed, inspect }

String taskLabel(FarmTask t) {
  switch (t) {
    case FarmTask.seed:
      return "Seed Field";
    case FarmTask.spray:
      return "Spray Crops";
    case FarmTask.weed:
      return "Remove Weeds";
    case FarmTask.inspect:
      return "Inspect Crops";
  }
}

IconData taskIcon(FarmTask t) {
  switch (t) {
    case FarmTask.seed:
      return Icons.grass;
    case FarmTask.spray:
      return Icons.water_drop;
    case FarmTask.weed:
      return Icons.eco;
    case FarmTask.inspect:
      return Icons.visibility;
  }
}

class AppFlow extends StatefulWidget {
  const AppFlow({super.key});

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  FarmTask? lastTask;

  Future<T?> push<T>(Widget screen) {
    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TelemetryProvider>().connect();
    });
  }

  void startNewTaskFlow() {
    push(
      TaskSelectionScreen(
        onSelect: (task) {
          push(ConfirmTaskScreen(task: task, onStart: () => startTask(task)));
        },
      ),
    );
  }

  void startTask(FarmTask task) {
    lastTask = task;
    push(
      WorkingScreen(
        task: task,
        totalRows: 12,
        initialRowDone: 0,
        onOpenManual: () => push(const ManualControlScreen()),
        onStop: () => Navigator.of(context).pop(), // back to previous
        onCompleted: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      onStartWork: startNewTaskFlow,
      onManualControl: () => push(const ManualControlScreen()),
      onOpenTechDashboard: () => push(const DashboardScreen()),
    );
  }
}
