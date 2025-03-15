import 'package:flutter/material.dart';
import 'package:smartnurse/utils/helpers.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Task Title')),
            TextField(
              decoration: InputDecoration(labelText: 'Task Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logic to save the task
                Navigator.pop(context);
                showSnackBar(context, 'Task saved successfully!');
              },
              child: Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
