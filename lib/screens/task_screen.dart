import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/nurse_service.dart';
import '../services/task_service.dart';
import '../widgets/task_list_item.dart';

class TaskScreen extends StatefulWidget {
  final String? nurseId;
  final bool showAssignButton;

  const TaskScreen({
    Key? key,
    this.nurseId,
    this.showAssignButton = false,
  }) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskService _taskService = TaskService();
  final NurseService _nurseService = NurseService();
  String _statusFilter = 'all';
  String _priorityFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_statusFilter != 'all' || _priorityFilter != 'all')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_statusFilter != 'all')
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text('Status: ${_statusFilter.toUpperCase()}'),
                          onDeleted: () =>
                              setState(() => _statusFilter = 'all'),
                        ),
                      ),
                    if (_priorityFilter != 'all')
                      Chip(
                        label:
                            Text('Priority: ${_priorityFilter.toUpperCase()}'),
                        onDeleted: () =>
                            setState(() => _priorityFilter = 'all'),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: widget.nurseId != null
                  ? _taskService.getTasksByNurse(widget.nurseId!)
                  : _taskService.getTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var tasks = snapshot.data ?? [];

                // Apply filters
                if (_statusFilter != 'all') {
                  tasks = tasks
                      .where((t) => t.status.toLowerCase() == _statusFilter)
                      .toList();
                }

                if (_priorityFilter != 'all') {
                  tasks = tasks
                      .where((t) => t.priority.toLowerCase() == _priorityFilter)
                      .toList();
                }

                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskListItem(
                      task: task,
                      showAssignButton: widget.showAssignButton &&
                          task.assignedNurseId == null,
                      onStatusChanged: widget.nurseId != null
                          ? (task, newStatus) {
                              _taskService.updateTaskStatus(task.id, newStatus);
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.showAssignButton
          ? FloatingActionButton(
              onPressed: _showAddTaskDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Status'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _statusFilter == 'all',
                  onSelected: (selected) {
                    setState(() => _statusFilter = 'all');
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _statusFilter == 'pending',
                  onSelected: (selected) {
                    setState(() => _statusFilter = 'pending');
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('In Progress'),
                  selected: _statusFilter == 'inProgress',
                  onSelected: (selected) {
                    setState(() => _statusFilter = 'inProgress');
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _statusFilter == 'completed',
                  onSelected: (selected) {
                    setState(() => _statusFilter = 'completed');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Priority'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _priorityFilter == 'all',
                  onSelected: (selected) {
                    setState(() => _priorityFilter = 'all');
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Low'),
                  selected: _priorityFilter == 'low',
                  onSelected: (selected) {
                    setState(() => _priorityFilter = 'low');
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('Medium'),
                  selected: _priorityFilter == 'medium',
                  onSelected: (selected) {
                    setState(() => _priorityFilter = 'medium');
                    Navigator.pop(context);
                  },
                ),
                FilterChip(
                  label: const Text('High'),
                  selected: _priorityFilter == 'high',
                  onSelected: (selected) {
                    setState(() => _priorityFilter = 'high');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String priority = 'medium';
    final selectedSpecializations = <String>{};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Priority'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Low'),
                    selected: priority == 'low',
                    onSelected: (selected) {
                      setState(() => priority = 'low');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Medium'),
                    selected: priority == 'medium',
                    onSelected: (selected) {
                      setState(() => priority = 'medium');
                    },
                  ),
                  ChoiceChip(
                    label: const Text('High'),
                    selected: priority == 'high',
                    onSelected: (selected) {
                      setState(() => priority = 'high');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Required Specializations'),
              const SizedBox(height: 8),
              StreamBuilder<List<String>>(
                stream: _nurseService.getAvailableSpecializations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final specializations = snapshot.data ?? [];
                  return Wrap(
                    spacing: 8,
                    children: specializations.map((spec) {
                      return FilterChip(
                        label: Text(spec),
                        selected: selectedSpecializations.contains(spec),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSpecializations.add(spec);
                            } else {
                              selectedSpecializations.remove(spec);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a title')),
                );
                return;
              }

              await _taskService.createTask(
                title: titleController.text,
                description: descriptionController.text,
                priority: priority,
                requiredSpecializations: selectedSpecializations.toList(),
              );

              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
