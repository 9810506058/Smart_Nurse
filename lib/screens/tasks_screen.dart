import 'package:flutter/material.dart';
import '../widgets/task_list_item.dart'; // Reusable task list item widget

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Handle filter functionality
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          TaskListItem(
            icon: Icons.timer,
            iconColor: Colors.red,
            title: 'Check vitals - Room 203',
            subtitle: 'John Smith • Due in 10 minutes',
          ),
          SizedBox(height: 8),
          TaskListItem(
            icon: Icons.medication,
            iconColor: Colors.orange,
            title: 'Administer medication - Room 105',
            subtitle: 'Emily Wilson • Due in 30 minutes',
          ),
          SizedBox(height: 8),
          TaskListItem(
            icon: Icons.assignment,
            iconColor: Colors.blue,
            title: 'Change dressing - Room 118',
            subtitle: 'Robert Davis • Due in 45 minutes',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add task screen
        },
        child: const Icon(Icons.add_task),
      ),
    );
  }
}
