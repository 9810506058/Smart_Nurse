import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/task_list_item.dart';
import '../widgets/patient_list_item.dart';
import '../widgets/medication_list_item.dart';
import '../models/task_model.dart';
import '../models/patient_model.dart';
import '../models/medication_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, Nurse Sarah',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have 12 patients and 8 pending tasks today',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upcoming tasks section
          Text(
            'Upcoming Tasks',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          _buildTasksList(),

          const SizedBox(height: 24),

          // Critical patients section
          Text(
            'Critical Patients',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          _buildCriticalPatientsList(),

          const SizedBox(height: 24),

          // Medication reminders section
          Text(
            'Medication Due',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          _buildMedicationList(),
        ],
      ),
    );
  }

  // Fetch and display tasks
  Widget _buildTasksList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('isCompleted', isEqualTo: false) // Fetch only pending tasks
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No tasks found'));
        }

        // Convert Firestore documents to Task objects
        final tasks = snapshot.data!.docs.map((doc) {
          return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: tasks.map((task) {
              return Column(
                children: [
                  TaskListItem(
                    icon: Icons.timer,
                    iconColor: Colors.red,
                    title: task.title,
                    subtitle: '${task.patientId} • Due at ${task.dueDate}',
                  ),
                  const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Fetch and display critical patients
  Widget _buildCriticalPatientsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
          .where('status',
              isEqualTo: 'Critical') // Fetch only critical patients
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No critical patients found'));
        }

        // Convert Firestore documents to Patient objects
        final patients = snapshot.data!.docs.map((doc) {
          return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: patients.map((patient) {
              return Column(
                children: [
                  PatientListItem(
                    initials: patient.name.substring(0, 2).toUpperCase(),
                    backgroundColor: _getColorForInitials(patient.name),
                    name: patient.name,
                    details:
                        'Room ${patient.roomNumber} • ${patient.status} • ${patient.notes}',
                    patientId: '${patient.id}',
                  ),
                  const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Fetch and display medication reminders
  Widget _buildMedicationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('medications')
          .where('isAdministered',
              isEqualTo: false) // Fetch only due medications
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No medication due'));
        }

        // Convert Firestore documents to Medication objects
        final medications = snapshot.data!.docs.map((doc) {
          return Medication.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: medications.map((medication) {
              return Column(
                children: [
                  MedicationListItem(
                    icon: Icons.medication,
                    iconColor: Colors.purple,
                    title: '${medication.name} - ${medication.patientId}',
                    subtitle: 'Due at ${medication.dueTime}',
                  ),
                  const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Helper function to generate a color based on patient initials
  Color _getColorForInitials(String name) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
    ];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
