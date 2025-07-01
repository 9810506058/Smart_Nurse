import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnurse/widgets/floating_action_button.dart';
import '../widgets/task_list_item.dart';
import '../widgets/patient_list_item.dart';
import '../widgets/medication_list_item.dart';
import '../widgets/dashboard_navigation_buttons.dart';
import '../models/task_model.dart';
import '../models/patient_model.dart';
import '../models/medication_model.dart';
import 'medications_screen.dart';
import 'nurse_dashboard.dart';
import 'patients_screen.dart';
import 'tasks_screen.dart';
import 'patient_details_screen.dart';

class DashboardScreenUpdated extends StatelessWidget {
  final String nurseId;
  final String nurseName;

  const DashboardScreenUpdated({
    Key? key,
    required this.nurseId,
    required this.nurseName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Smart Nurse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NurseDashboard(nurseId: nurseId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile', arguments: nurseId);
            },
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(nurseId: nurseId),
      body: RefreshIndicator(
        onRefresh: () async {
          // Force refresh of Firestore streams
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingCard(context),
              const SizedBox(height: 24),
              DashboardNavigationButtons(nurseId: nurseId),
              const SizedBox(height: 24),
              _buildTasksSection(context),
              const SizedBox(height: 24),
              _buildCriticalPatientsSection(context),
              const SizedBox(height: 24),
              _buildMedicationSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No upcoming tasks assigned',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          );
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

        if (tasks.isEmpty) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No upcoming tasks assigned',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          );
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(tasks.length, (index) {
              final task = tasks[index];
              return Column(
                children: [
                  TaskListItem(
                    task: task,
                    onStatusChanged: (task, status) =>
                        _updateTaskStatus(task, status == 'completed'),
                  ),
                  if (index < tasks.length - 1)
                    const Divider(height: 1, thickness: 1),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildCriticalPatientsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
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
          return const Center(child: Text('No critical patients'));
        }

        final patients = snapshot.data!.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Patient.fromMap(data, doc.id);
            })
            .where((patient) => patient.status == 'critical')
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(patients.length, (index) {
              final patient = patients[index];
              return Column(
                children: [
                  PatientListItem(
                    patient: patient,
                    onTap: () => _handlePatientTap(context, patient),
                  ),
                  if (index < patients.length - 1)
                    const Divider(height: 1, thickness: 1),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildMedicationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
          .where('assignedNurseId', isEqualTo: nurseId)
          .snapshots(),
      builder: (context, patientSnapshot) {
        if (patientSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (patientSnapshot.hasError) {
          return Center(child: Text('Error: ${patientSnapshot.error}'));
        }

        final patientMap = <String, String>{};
        if (patientSnapshot.hasData) {
          for (var doc in patientSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            patientMap[doc.id] = data['name'] as String? ?? 'Unknown Patient';
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('medications')
              .where('isAdministered', isEqualTo: false)
              .snapshots(),
          builder: (context, medicationSnapshot) {
            if (medicationSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (medicationSnapshot.hasError) {
              return Center(child: Text('Error: ${medicationSnapshot.error}'));
            }

            if (!medicationSnapshot.hasData ||
                medicationSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No medication due soon'));
            }

            final now = DateTime.now();
            final medications = medicationSnapshot.data!.docs
                .map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Medication.fromMap(data, doc.id);
                })
                .where((medication) =>
                    !medication.isAdministered &&
                    medication.dueTime
                        .isBefore(now.add(const Duration(hours: 24))))
                .toList()
              ..sort((a, b) => a.dueTime.compareTo(b.dueTime));

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: List.generate(medications.length, (index) {
                  final medication = medications[index];
                  final patientName =
                      patientMap[medication.patientId] ?? 'Unknown Patient';
                  return Column(
                    children: [
                      MedicationListItem(
                        icon: Icons.medication,
                        iconColor: Theme.of(context).colorScheme.primary,
                        title: '${medication.name} - For $patientName',
                        subtitle: 'Due at ${_formatTime(medication.dueTime)}',
                        medication: medication,
                        onTap: () => _navigateToMedicationsScreen(context),
                        onAdministeredChanged: (value) =>
                            _updateMedicationStatus(medication, value),
                      ),
                      if (index < medications.length - 1)
                        const Divider(height: 1, thickness: 1),
                    ],
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.waving_hand,
                    color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 8),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('nurses')
                      .doc(nurseId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text(
                        '$greeting, Nurse',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      );
                    }
                    final nurseName = snapshot.data?.get('name') ?? 'Nurse';
                    return Text(
                      '$greeting, $nurseName',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patients')
                  .where('assignedNurseId', isEqualTo: nurseId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingText(context);
                }
                if (snapshot.hasError) {
                  return _buildErrorText(context, 'Error loading patient data');
                }

                final patientCount = snapshot.data?.docs.length ?? 0;
                return FutureBuilder<int>(
                  future: _getPendingTaskCount(),
                  builder: (context, taskSnapshot) {
                    final taskCount = taskSnapshot.data ?? 0;
                    return Text(
                      'You have $patientCount patients and $taskCount pending tasks',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[800],
                          ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Upcoming Tasks',
          Icons.assignment,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildTasksList(context),
      ],
    );
  }

  Widget _buildCriticalPatientsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Critical Patients',
          Icons.warning,
          Colors.red,
        ),
        const SizedBox(height: 8),
        _buildCriticalPatientsList(),
      ],
    );
  }

  Widget _buildMedicationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Medication Due',
          Icons.medication,
          Colors.purple,
        ),
        const SizedBox(height: 8),
        _buildMedicationList(),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
        ),
      ],
    );
  }

  Future<int> _getPendingTaskCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('assignedNurseId', isEqualTo: nurseId)
          .where('isCompleted', isEqualTo: false)
          .count()
          .get();
      return snapshot.count;
    } catch (e) {
      debugPrint('Error counting tasks: $e');
      return 0;
    }
  }

  void _handleTaskTap(BuildContext context, Task task) {
    // Implement navigation to task details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task details: ${task.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _updateTaskStatus(Task task, bool isCompleted) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating task status: $e');
    }
  }

  void _navigateToMedicationsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicationsScreen(),
      ),
    );
  }

  Future<void> _updateMedicationStatus(
      Medication medication, bool isAdministered) async {
    try {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(medication.id)
          .update({
        'isAdministered': isAdministered,
        'administeredBy': nurseId,
        'administeredAt': isAdministered ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating medication status: $e');
    }
  }

  Widget _buildLoadingText(BuildContext context) {
    return Text(
      'Loading data...',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
    );
  }

  Widget _buildErrorText(BuildContext context, String message) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.red,
          ),
    );
  }

  Color _getColorForInitials(String name) {
    if (name.isEmpty) return Colors.blue;
    final colors = [
      Colors.red.shade300,
      Colors.orange.shade300,
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.purple.shade300,
      Colors.teal.shade300,
    ];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  void _handlePatientTap(BuildContext context, Patient patient) {
    // Implement navigation to patient details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(patient: patient),
      ),
    );
  }

  Widget _buildPatientsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'No patients assigned',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final patients = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Patient.fromMap(data, doc.id);
        }).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    patient.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(patient.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room: ${patient.room}'),
                    Text('Status: ${patient.status}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PatientDetailsScreen(patient: patient),
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PatientDetailsScreen(patient: patient),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
