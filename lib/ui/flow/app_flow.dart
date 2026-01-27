import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/telemetry_provider.dart';
import '../dashboard_screen.dart'; // if you want to keep your old dashboard
import 'screens/home_screen.dart';
import 'screens/task_selection_screen.dart';
import 'screens/confirm_task_screen.dart';
import 'screens/working_screen.dart';
import 'screens/manual_control_screen.dart';
import 'screens/report_screen.dart';

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
  // App state (later you can move into provider)
  FarmTask? selectedTask;
  bool isWorking = false;
  bool isPaused = false;

  // Fake progress (replace with real mission logic)
  int rowDone = 4;
  int totalRows = 12;

  @override
  void initState() {
    super.initState();
    // auto-connect socket on app open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TelemetryProvider>().connect();
    });
  }

  void _go(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _startTask(FarmTask task) {
    setState(() {
      selectedTask = task;
      isWorking = true;
      isPaused = false;
    });
    _go(
      WorkingScreen(
        task: task,
        totalRows: totalRows,
        rowDone: rowDone,
        onPause: () => setState(() => isPaused = true),
        onResume: () => setState(() => isPaused = false),
        onStop: () {
          setState(() {
            isWorking = false;
            isPaused = false;
          });
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
        onOpenManual: () => _go(const ManualControlScreen()),
        onCompleted: () => _go(
          ReportScreen(
            task: task,
            totalRows: totalRows,
            timeTakenMin: 42,
            batteryUsedPercent: 18,
            laborSavedHours: 2,
            onNewTask: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
              _go(
                TaskSelectionScreen(
                  onSelect: (t) =>
                      _go(ConfirmTaskScreen(task: t, onStart: _startTask)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      totalRows: totalRows,
      rowDone: rowDone,
      onStartWork: () {
        _go(
          TaskSelectionScreen(
            onSelect: (t) =>
                _go(ConfirmTaskScreen(task: t, onStart: _startTask)),
          ),
        );
      },
      onManualControl: () => _go(const ManualControlScreen()),
      onReports: () => _go(
        ReportScreen(
          task: selectedTask ?? FarmTask.inspect,
          totalRows: totalRows,
          timeTakenMin: 42,
          batteryUsedPercent: 18,
          laborSavedHours: 2,
          onNewTask: () {
            Navigator.of(context).popUntil((r) => r.isFirst);
            _go(
              TaskSelectionScreen(
                onSelect: (t) =>
                    _go(ConfirmTaskScreen(task: t, onStart: _startTask)),
              ),
            );
          },
        ),
      ),
      onOpenTechDashboard: () => _go(const DashboardScreen()), // optional
    );
  }
}
