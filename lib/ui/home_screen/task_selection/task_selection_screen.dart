import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/custom_component/custom_appbar.dart';
import 'package:electro_farm/ui/home_screen/task_selection/working_screen.dart';
import 'package:electro_farm/ui/home_screen/home_screen.dart';
import 'package:electro_farm/ui/home_screen/task_selection/confirm_task_screen.dart';
import 'package:electro_farm/ui/home_screen/view/manual_control_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskSelectionScreen extends StatelessWidget {
  TaskSelectionScreen({super.key});

  String _desc(FarmTask t) {
    switch (t) {
      case FarmTask.spray:
        return "Autonomous spraying along rows with obstacle safety.";
      case FarmTask.inspect:
        return "Capture crop images + health monitoring + map points.";
    }
  }

  String _tag(FarmTask t) {
    switch (t) {
      case FarmTask.spray:
        return "Most Used";
      case FarmTask.inspect:
        return "AI Ready";
    }
  }

  Color _tagColor(FarmTask t) {
    switch (t) {
      case FarmTask.spray:
        return const Color(0xFF001631);
      case FarmTask.inspect:
        return const Color(0xFF435E91);
    }
  }

  Color _gradientStart(FarmTask t) {
    switch (t) {
      case FarmTask.spray:
        return AppColors.onBackground.withValues(alpha: 0.8);
      case FarmTask.inspect:
        return AppColors.primary.withValues(alpha: 0.8);
    }
  }

  Color _gradientEnd(FarmTask t) {
    switch (t) {
      case FarmTask.spray:
        return AppColors.primary;
      case FarmTask.inspect:
        return AppColors.primary;
    }
  }

  FarmTask? lastTask;

  Future<T?> push<T>(Widget screen, BuildContext context) {
    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (_) => screen));
  }

  void startTask(FarmTask task, BuildContext context) {
    lastTask = task;
    push(
      WorkingScreen(
        task: task,
        totalRows: 12,
        initialRowDone: 0,
        onOpenManual: () => push(const ManualControlScreen(), context),
        onStop: () => Navigator.of(context).pop(),
        onCompleted: () {},
      ),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = FarmTask.values;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: ElectrofarmAppBar(
        title: "Select Task",
        backgroundColor: colorScheme.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose Task",
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select an operation to begin autonomous execution",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Task Cards
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final t = tasks[index];
                    return _TaskCard(
                      task: t,
                      tag: _tag(t),
                      desc: _desc(t),
                      tagColor: _tagColor(t),
                      gradientStart: _gradientStart(t),
                      gradientEnd: _gradientEnd(t),
                      onTap: () => push(
                        ConfirmTaskScreen(
                          task: t,
                          onStart: () => startTask(t, context),
                        ),
                        context,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final FarmTask task;
  final String tag;
  final String desc;
  final Color tagColor;
  final Color gradientStart;
  final Color gradientEnd;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.tag,
    required this.desc,
    required this.tagColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.surfaceContainerLowest,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: .3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Container with Gradient
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [gradientStart, gradientEnd],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientStart.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(taskIcon(task), color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskLabel(task),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: colorScheme.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: tagColor.withOpacity(isDark ? 0.2 : 0.08),
                          border: Border.all(
                            color: tagColor.withOpacity(0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tagColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tag,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: tagColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron with subtle animation effect
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withOpacity(0.08),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to get icon for FarmTask
IconData taskIcon(FarmTask task) {
  switch (task) {
    case FarmTask.spray:
      return Icons.grass_rounded;
    case FarmTask.inspect:
      return Icons.photo_camera_rounded;
  }
}

// Extension to get label for FarmTask
String taskLabel(FarmTask task) {
  switch (task) {
    case FarmTask.spray:
      return "Spray Application";
    case FarmTask.inspect:
      return "Crop Inspection";
  }
}
