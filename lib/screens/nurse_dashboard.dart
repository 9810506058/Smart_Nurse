import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/patient_model.dart';
import '../services/task_service.dart';
import '../services/patient_service.dart';
import '../widgets/task_list_item.dart';
import '../widgets/patient_list_item.dart';

class NurseDashboard extends StatefulWidget {
  final String nurseId;

  const NurseDashboard({Key? key, required this.nurseId}) : super(key: key);

  @override
  State<NurseDashboard> createState() => _NurseDashboardState();
}

class _NurseDashboardState extends State<NurseDashboard> {
  final TaskService _taskService = TaskService();
  final PatientService _patientService = PatientService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nurse Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile screen
              Navigator.pushNamed(context, '/profile',
                  arguments: widget.nurseId);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWorkloadCard(),
          const SizedBox(height: 16),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.blue,
                    tabs: [
                      Tab(text: 'My Tasks'),
                      Tab(text: 'My Patients'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTasksTab(),
                        _buildPatientsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add new patient
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildWorkloadCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Workload',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '5/10 Tasks',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWorkloadStat('Pending', '3', Colors.orange),
                  _buildWorkloadStat('In Progress', '2', Colors.blue),
                  _buildWorkloadStat('Completed', '8', Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkloadStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTasksTab() {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasksByNurse(widget.nurseId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!;
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskListItem(
              task: tasks[index],
              onStatusChanged: (Task task, String newStatus) {
                _taskService.updateTaskStatus(task.id, newStatus);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPatientsTab() {
    return StreamBuilder<List<Patient>>(
      stream: _patientService.getPatientsByNurse(widget.nurseId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final patients = snapshot.data!;
        return ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            return PatientListItem(patient: patients[index]);
          },
        );
      },
    );
  }
}
