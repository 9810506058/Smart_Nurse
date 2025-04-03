import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../widgets/task_list_item.dart';

class TasksScreen extends StatelessWidget {
  final String nurseId;

  const TasksScreen({
    Key? key,
    required this.nurseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('assignedNurseId', isEqualTo: nurseId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks found'));
          }

          final tasks = snapshot.data!.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return Task.fromMap(data);
              })
              .where((task) => task.status != 'completed')
              .toList()
            ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskListItem(
                task: task,
                onStatusChanged: (task, status) =>
                    _updateTaskStatus(task, status == 'completed'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add task functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add task functionality coming soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _updateTaskStatus(Task task, bool isCompleted) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
        'status': isCompleted ? 'completed' : 'inProgress',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating task status: $e');
    }
  }
}
