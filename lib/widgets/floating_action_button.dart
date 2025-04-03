import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnurse/screens/add_patient_screen.dart';
import 'package:smartnurse/screens/add_task_screen.dart';
import 'package:smartnurse/screens/record_medication_screen.dart';
import 'package:smartnurse/screens/record_vitals_screen.dart';
import '../models/patient_model.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Add new item',
      onPressed: () => _showActionMenu(context),
      child: const Icon(Icons.add),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildActionSheet(context),
    );
  }

  Widget _buildActionSheet(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Create New',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildActionItem(
            context,
            icon: Icons.person_add,
            label: 'Add Patient',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPatientScreen(),
                ),
              );
            },
          ),
          _buildActionItem(
            context,
            icon: Icons.task_alt,
            label: 'Add Task',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTaskScreen(),
                ),
              );
            },
          ),
          _buildActionItem(
            context,
            icon: Icons.medication,
            label: 'Record Medication',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecordMedicationScreen(),
                ),
              );
            },
          ),
          _buildActionItem(
            context,
            icon: Icons.favorite,
            label: 'Record Vitals',
            onTap: () {
              Navigator.pop(context);
              _selectPatientForVitals(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectPatientForVitals(BuildContext context) async {
    final patient = await showDialog<Patient?>(
      context: context,
      builder: (context) => _buildPatientSelectionDialog(context),
    );

    if (patient != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecordVitalsScreen(patientId: patient.id),
        ),
      );
    }
  }

  Widget _buildPatientSelectionDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Patient'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('patients')
              .orderBy('name')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading patients: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No patients found'));
            }

            final patients = snapshot.data!.docs.map((doc) {
              return Patient.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();

            return ListView.builder(
              shrinkWrap: true,
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(patient.name),
                    subtitle: Text('Room ${patient.roomNumber}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pop(context, patient),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
