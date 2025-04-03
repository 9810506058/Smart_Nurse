import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nurse_model.dart';
import '../models/task_model.dart';
import '../services/nurse_service.dart';
import '../services/task_service.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({Key? key}) : super(key: key);

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final NurseService _nurseService = NurseService();
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Supervisor Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tasks'),
              Tab(text: 'Nurses'),
              Tab(text: 'Patients'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTasksTab(),
            _buildNursesTab(),
            _buildPatientsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Task Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _createNewTask,
                icon: const Icon(Icons.add),
                tooltip: 'Create Task',
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Task>>(
            stream: _taskService.getTasks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final tasks = snapshot.data ?? [];
              final pendingTasks =
                  tasks.where((t) => t.status == 'pending').toList();
              final inProgressTasks =
                  tasks.where((t) => t.status == 'inProgress').toList();
              final completedTasks =
                  tasks.where((t) => t.status == 'completed').toList();

              return Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey[600],
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tabs: [
                            _buildTabWithCount('Pending', pendingTasks.length),
                            _buildTabWithCount(
                                'In Progress', inProgressTasks.length),
                            _buildTabWithCount(
                                'Completed', completedTasks.length),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildTaskList(pendingTasks),
                            _buildTaskList(inProgressTasks),
                            _buildTaskList(completedTasks),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithCount(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No tasks found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Icon(
                task.status == 'completed'
                    ? Icons.check_circle
                    : task.status == 'inProgress'
                        ? Icons.sync
                        : Icons.pending_actions,
                color: _getStatusColor(task.status),
              ),
              title: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Chip(
                label: Text(
                  task.priority,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor:
                    _getPriorityColor(task.priority).withOpacity(0.2),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildPriorityChip(task.priority),
                          const SizedBox(width: 8),
                          _buildStatusChip(task.status),
                        ],
                      ),
                      if (task.requiredSpecializations.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Required Specializations:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: task.requiredSpecializations
                              .map((spec) => Chip(
                                    label: Text(spec),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (task.status != 'completed')
                            TextButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text('Mark Complete'),
                              onPressed: () => _markTaskAsComplete(task),
                            ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            onPressed: () => _deleteTask(task),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'inprogress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _createNewTask() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String priority = 'medium';
    final specializations = <String>{};

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) => title = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) => description = value ?? '',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  value: priority,
                  items: ['low', 'medium', 'high'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => priority = value ?? 'medium',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Required Specializations:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'General Care',
                    'Critical Care',
                    'Emergency Care',
                    'Pediatrics',
                    'Surgery',
                    'Intensive Care',
                  ].map((spec) {
                    final isSelected = specializations.contains(spec);
                    return FilterChip(
                      label: Text(spec),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            specializations.add(spec);
                          } else {
                            specializations.remove(spec);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate() &&
                            specializations.isNotEmpty) {
                          formKey.currentState!.save();
                          try {
                            await _taskService.createTask(
                              title: title,
                              description: description,
                              priority: priority,
                              requiredSpecializations: specializations.toList(),
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Task created successfully')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error creating task: $e')),
                              );
                            }
                          }
                        } else if (specializations.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please select at least one specialization')),
                          );
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _markTaskAsComplete(Task task) async {
    try {
      await _taskService.updateTaskStatus(task.id, 'completed');
      if (task.assignedNurseId != null) {
        final nurse =
            await _nurseService.getNurseByUserId(task.assignedNurseId!);
        if (nurse != null) {
          await _nurseService.updateNurseWorkload(
            nurse.id,
            nurse.currentWorkload - 1,
          );
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task marked as complete')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _taskService.deleteTask(task.id);
        if (task.assignedNurseId != null) {
          final nurse =
              await _nurseService.getNurseByUserId(task.assignedNurseId!);
          if (nurse != null) {
            await _nurseService.updateNurseWorkload(
              nurse.id,
              nurse.currentWorkload - 1,
            );
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting task: $e')),
          );
        }
      }
    }
  }

  Widget _buildNursesTab() {
    return StreamBuilder<List<Nurse>>(
      stream: _nurseService.getNurses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final nurses = snapshot.data ?? [];
        if (nurses.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No nurses found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nurse Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _createNewPatient,
                    icon: const Icon(Icons.person_add),
                    tooltip: 'Add Patient',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildNurseStats(nurses),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: nurses.length,
                  itemBuilder: (context, index) {
                    final nurse = nurses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                nurse.currentWorkload >= nurse.maxWorkload
                                    ? Colors.red[100]
                                    : Colors.green[100],
                            radius: 20,
                            child: Text(
                              nurse.name[0],
                              style: TextStyle(
                                color:
                                    nurse.currentWorkload >= nurse.maxWorkload
                                        ? Colors.red[900]
                                        : Colors.green[900],
                              ),
                            ),
                          ),
                          title: Text(
                            nurse.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${nurse.role} - ${nurse.shift} shift',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: nurse.currentWorkload >= nurse.maxWorkload
                                  ? Colors.red[50]
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    nurse.currentWorkload >= nurse.maxWorkload
                                        ? Colors.red[200]!
                                        : Colors.green[200]!,
                              ),
                            ),
                            child: Text(
                              '${nurse.currentWorkload}/${nurse.maxWorkload}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    nurse.currentWorkload >= nurse.maxWorkload
                                        ? Colors.red[900]
                                        : Colors.green[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Specializations:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: nurse.specializations.map((spec) {
                                      return Chip(
                                        label: Text(
                                          spec,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _viewNurseProgress(nurse),
                                          icon: const Icon(Icons.bar_chart,
                                              size: 16),
                                          label: const Text('Progress'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => _assignTask(nurse),
                                          icon: const Icon(Icons.assignment,
                                              size: 16),
                                          label: const Text('Tasks'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _assignPatient(nurse),
                                          icon: const Icon(Icons.person_add,
                                              size: 16),
                                          label: const Text('Assign Patient'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => _updateShift(nurse),
                                          icon: const Icon(Icons.schedule,
                                              size: 16),
                                          label: const Text('Shift'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNurseStats(List<Nurse> nurses) {
    final totalNurses = nurses.length;
    final availableNurses =
        nurses.where((n) => n.currentWorkload < n.maxWorkload).length;
    final morningShift = nurses.where((n) => n.shift == 'morning').length;
    final eveningShift = nurses.where((n) => n.shift == 'evening').length;
    final nightShift = nurses.where((n) => n.shift == 'night').length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    totalNurses.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    availableNurses.toString(),
                    Icons.person_outline,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Morning',
                    morningShift.toString(),
                    Icons.wb_sunny,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Evening',
                    eveningShift.toString(),
                    Icons.wb_twilight,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Night',
                    nightShift.toString(),
                    Icons.nightlight_round,
                    Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _viewNurseProgress(Nurse nurse) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${nurse.name}\'s Progress',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Task>>(
                stream: _taskService.getTasksByNurse(nurse.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final tasks = snapshot.data ?? [];
                  final completedTasks =
                      tasks.where((t) => t.status == 'completed').length;
                  final totalTasks = tasks.length;
                  final completionRate =
                      totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressSection(
                          'Task Completion Rate', completionRate.toDouble()),
                      const SizedBox(height: 16),
                      _buildProgressSection('Workload',
                          (nurse.currentWorkload / nurse.maxWorkload * 100)),
                      const SizedBox(height: 16),
                      const Text(
                        'Recent Tasks:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return ListTile(
                              title: Text(task.title),
                              subtitle: Text(task.status),
                              trailing: Icon(
                                task.status == 'completed'
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: task.status == 'completed'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(String label, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage >= 80 ? Colors.red : Colors.blue,
          ),
        ),
      ],
    );
  }

  void _assignTask(Nurse nurse) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assign Task to ${nurse.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Task>>(
                stream: _taskService.getTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final allTasks = snapshot.data ?? [];
                  final unassignedTasks =
                      allTasks.where((t) => t.assignedNurseId == null).toList();

                  if (unassignedTasks.isEmpty) {
                    return const Text('No unassigned tasks available');
                  }

                  return Column(
                    children: [
                      const Text(
                        'Available Tasks:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: unassignedTasks.length,
                          itemBuilder: (context, index) {
                            final task = unassignedTasks[index];
                            final canAssign = nurse.currentWorkload <
                                    nurse.maxWorkload &&
                                nurse.specializations.any((s) =>
                                    task.requiredSpecializations.contains(s));

                            return ListTile(
                              title: Text(task.title),
                              subtitle: Text(task.description),
                              trailing: IconButton(
                                icon: const Icon(Icons.assignment_turned_in),
                                onPressed: canAssign
                                    ? () async {
                                        try {
                                          await _taskService.assignTask(
                                              task.id, nurse.id);
                                          await _nurseService
                                              .updateNurseWorkload(
                                            nurse.id,
                                            nurse.currentWorkload + 1,
                                          );
                                          if (mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Task assigned successfully')),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error assigning task: $e')),
                                            );
                                          }
                                        }
                                      }
                                    : null,
                                tooltip: canAssign
                                    ? 'Assign Task'
                                    : 'Cannot assign task (workload full or missing specialization)',
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateShift(Nurse nurse) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update ${nurse.name}\'s Shift',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _updateNurseShift(nurse, 'morning'),
                    child: const Text('Morning'),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateNurseShift(nurse, 'evening'),
                    child: const Text('Evening'),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateNurseShift(nurse, 'night'),
                    child: const Text('Night'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateNurseShift(Nurse nurse, String shift) async {
    try {
      await _nurseService.updateNurseShift(nurse.id, shift);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating shift: $e')),
        );
      }
    }
  }

  void _assignPatient(Nurse nurse) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assign Patient to ${nurse.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('patients')
                    .where('assignedNurseId', isNull: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final unassignedPatients = snapshot.data?.docs ?? [];

                  if (unassignedPatients.isEmpty) {
                    return const Text('No unassigned patients available');
                  }

                  return Column(
                    children: [
                      const Text(
                        'Available Patients:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: unassignedPatients.length,
                          itemBuilder: (context, index) {
                            final patientDoc = unassignedPatients[index];
                            final patientData =
                                patientDoc.data() as Map<String, dynamic>;
                            final patientName =
                                patientData['name'] as String? ??
                                    'Unknown Patient';

                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(patientName[0]),
                              ),
                              title: Text(patientName),
                              subtitle: Text(
                                  patientData['room'] ?? 'No room assigned'),
                              trailing: IconButton(
                                icon: const Icon(Icons.assignment_turned_in),
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('patients')
                                        .doc(patientDoc.id)
                                        .update({
                                      'assignedNurseId': nurse.id,
                                      'assignedAt':
                                          FieldValue.serverTimestamp(),
                                    });

                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Patient assigned successfully'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error assigning patient: $e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewPatient() {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String room = '';
    String status = 'stable';
    int roomNumber = 0;
    int bedNumber = 0;
    String notes = '';
    final conditions = <String>[];
    final allergies = <String>[];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Patient',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter patient name';
                      }
                      return null;
                    },
                    onSaved: (value) => name = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Room',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter room';
                      }
                      return null;
                    },
                    onSaved: (value) => room = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: status,
                    items: ['stable', 'critical', 'recovering']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => status = value ?? 'stable',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Room Number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          onSaved: (value) =>
                              roomNumber = int.tryParse(value ?? '') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Bed Number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          onSaved: (value) =>
                              bedNumber = int.tryParse(value ?? '') ?? 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onSaved: (value) => notes = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Conditions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      'Hypertension',
                      'Diabetes',
                      'Heart Disease',
                      'Respiratory Issues',
                      'Other',
                    ].map((condition) {
                      final isSelected = conditions.contains(condition);
                      return FilterChip(
                        label: Text(condition),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            conditions.add(condition);
                          } else {
                            conditions.remove(condition);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Allergies:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      'Penicillin',
                      'Latex',
                      'Food Allergies',
                      'None',
                    ].map((allergy) {
                      final isSelected = allergies.contains(allergy);
                      return FilterChip(
                        label: Text(allergy),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            allergies.add(allergy);
                          } else {
                            allergies.remove(allergy);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            try {
                              await FirebaseFirestore.instance
                                  .collection('patients')
                                  .add({
                                'name': name,
                                'room': room,
                                'status': status,
                                'roomNumber': roomNumber,
                                'bedNumber': bedNumber,
                                'notes': notes,
                                'conditions': conditions,
                                'allergies': allergies,
                                'createdAt': FieldValue.serverTimestamp(),
                                'updatedAt': FieldValue.serverTimestamp(),
                              });
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Patient added successfully')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error adding patient: $e')),
                                );
                              }
                            }
                          }
                        },
                        child: const Text('Add Patient'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority) {
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
        priority,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.grey;
        break;
      case 'inProgress':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  void _assignTaskToNurse(Task task) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assign Task',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Nurse>>(
                stream: _nurseService.getNurses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final nurses = snapshot.data ?? [];
                  final availableNurses = nurses
                      .where((n) =>
                          n.currentWorkload < n.maxWorkload &&
                          n.specializations.any(
                              (s) => task.requiredSpecializations.contains(s)))
                      .toList();

                  if (availableNurses.isEmpty) {
                    return const Text(
                        'No available nurses with matching specializations');
                  }

                  return Column(
                    children: [
                      const Text(
                        'Available Nurses:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: availableNurses.length,
                          itemBuilder: (context, index) {
                            final nurse = availableNurses[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text(nurse.name[0])),
                              title: Text(nurse.name),
                              subtitle:
                                  Text('${nurse.role} - ${nurse.shift} shift'),
                              trailing: Text(
                                  '${nurse.currentWorkload}/${nurse.maxWorkload}'),
                              onTap: () async {
                                try {
                                  await _taskService.assignTask(
                                      task.id, nurse.id);
                                  await _nurseService.updateNurseWorkload(
                                    nurse.id,
                                    nurse.currentWorkload + 1,
                                  );
                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Task assigned successfully')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Error assigning task: $e')),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientsTab() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Patient Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _createNewPatient,
                icon: const Icon(Icons.person_add),
                tooltip: 'Add Patient',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('patients').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final patients = snapshot.data?.docs ?? [];
                if (patients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No patients found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patientDoc = patients[index];
                    final patientData =
                        patientDoc.data() as Map<String, dynamic>;
                    final assignedNurseId =
                        patientData['assignedNurseId'] as String?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: assignedNurseId == null
                                ? Colors.orange[100]
                                : Colors.green[100],
                            child: Text(
                              patientData['name'][0],
                              style: TextStyle(
                                color: assignedNurseId == null
                                    ? Colors.orange[900]
                                    : Colors.green[900],
                              ),
                            ),
                          ),
                          title: Text(patientData['name']),
                          subtitle: Text('Room: ${patientData['room']}'),
                          trailing: assignedNurseId == null
                              ? const Icon(Icons.warning, color: Colors.orange)
                              : null,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                      'Status', patientData['status']),
                                  _buildInfoRow('Room Number',
                                      patientData['roomNumber'].toString()),
                                  _buildInfoRow('Bed Number',
                                      patientData['bedNumber'].toString()),
                                  if (patientData['notes']?.isNotEmpty ?? false)
                                    _buildInfoRow(
                                        'Notes', patientData['notes']),
                                  if ((patientData['conditions'] as List?)
                                          ?.isNotEmpty ??
                                      false) ...[
                                    const SizedBox(height: 8),
                                    const Text('Conditions:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Wrap(
                                      spacing: 4,
                                      children:
                                          (patientData['conditions'] as List)
                                              .map((condition) =>
                                                  Chip(label: Text(condition)))
                                              .toList(),
                                    ),
                                  ],
                                  if ((patientData['allergies'] as List?)
                                          ?.isNotEmpty ??
                                      false) ...[
                                    const SizedBox(height: 8),
                                    const Text('Allergies:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Wrap(
                                      spacing: 4,
                                      children:
                                          (patientData['allergies'] as List)
                                              .map((allergy) =>
                                                  Chip(label: Text(allergy)))
                                              .toList(),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (assignedNurseId == null)
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _assignPatientToNurse(
                                                  patientDoc.id),
                                          icon: const Icon(Icons.person_add),
                                          label: const Text('Assign Nurse'),
                                        ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _deletePatient(patientDoc.id),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _assignPatientToNurse(String patientId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assign Nurse',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Nurse>>(
                stream: _nurseService.getNurses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final nurses = snapshot.data ?? [];
                  final availableNurses = nurses
                      .where((n) => n.currentWorkload < n.maxWorkload)
                      .toList();

                  if (availableNurses.isEmpty) {
                    return const Text('No available nurses');
                  }

                  return Column(
                    children: [
                      const Text(
                        'Available Nurses:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: availableNurses.length,
                          itemBuilder: (context, index) {
                            final nurse = availableNurses[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text(nurse.name[0])),
                              title: Text(nurse.name),
                              subtitle:
                                  Text('${nurse.role} - ${nurse.shift} shift'),
                              trailing: Text(
                                  '${nurse.currentWorkload}/${nurse.maxWorkload}'),
                              onTap: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('patients')
                                      .doc(patientId)
                                      .update({
                                    'assignedNurseId': nurse.id,
                                    'assignedAt': FieldValue.serverTimestamp(),
                                  });
                                  await _nurseService.updateNurseWorkload(
                                    nurse.id,
                                    nurse.currentWorkload + 1,
                                  );
                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Patient assigned successfully')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error assigning patient: $e')),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deletePatient(String patientId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: const Text('Are you sure you want to delete this patient?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final patientDoc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .get();
        final patientData = patientDoc.data() as Map<String, dynamic>;
        final assignedNurseId = patientData['assignedNurseId'] as String?;

        await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .delete();

        if (assignedNurseId != null) {
          final nurse = await _nurseService.getNurseByUserId(assignedNurseId);
          if (nurse != null) {
            await _nurseService.updateNurseWorkload(
              nurse.id,
              nurse.currentWorkload - 1,
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting patient: $e')),
          );
        }
      }
    }
  }
}
