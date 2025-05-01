import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../screens/task_screen.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final bool showAssignButton;
  final Function(Task, String)? onStatusChanged;

  const TaskListItem({
    Key? key,
    required this.task,
    this.showAssignButton = false,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskScreen(
                nurseId: task.assignedNurseId,
                showAssignButton: showAssignButton,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 8),
              Text(task.description),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip(),
                  const SizedBox(width: 8),
                  if (task.requiredSpecializations.isNotEmpty) ...[
                    const Text('Required: '),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children: task.requiredSpecializations
                            .map((spec) => Chip(
                                  label: Text(spec),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
              if (onStatusChanged != null && !showAssignButton) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: task.status == 'pending'
                          ? () => onStatusChanged!(task, 'inProgress')
                          : null,
                      child: const Text('Start'),
                    ),
                    TextButton(
                      onPressed: task.status == 'inProgress'
                          ? () => onStatusChanged!(task, 'completed')
                          : null,
                      child: const Text('Complete'),
                    ),
                  ],
                ),
              ],
              if (showAssignButton && task.assignedNurseId == null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Show assign dialog
                    },
                    child: const Text('Assign'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    switch (task.status.toLowerCase()) {
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'inprogress':
        chipColor = Colors.blue;
        break;
      case 'pending':
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        task.status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  Widget _buildPriorityChip() {
    Color color;
    switch (task.priority) {
      case 'low':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'high':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        task.priority,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
