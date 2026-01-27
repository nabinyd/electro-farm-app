import 'package:flutter/material.dart';
import '../app_flow.dart';

class TaskSelectionScreen extends StatelessWidget {
  final void Function(FarmTask task) onSelect;

  const TaskSelectionScreen({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Task")),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What do you want to do?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),

            _TaskTile(
              task: FarmTask.seed,
              onTap: () => onSelect(FarmTask.seed),
            ),
            _TaskTile(
              task: FarmTask.spray,
              onTap: () => onSelect(FarmTask.spray),
            ),
            _TaskTile(
              task: FarmTask.weed,
              onTap: () => onSelect(FarmTask.weed),
            ),
            _TaskTile(
              task: FarmTask.inspect,
              onTap: () => onSelect(FarmTask.inspect),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final FarmTask task;
  final VoidCallback onTap;
  const _TaskTile({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(taskIcon(task), size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  taskLabel(task),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
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
