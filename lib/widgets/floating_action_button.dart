import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnurse/screens/add_patient_screen.dart';
import 'package:smartnurse/screens/add_task_screen.dart';
import 'package:smartnurse/screens/record_medication_screen.dart';
import 'package:smartnurse/screens/record_vitals_screen.dart';
import '../models/patient_model.dart';
import '../models/nurse_model.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final String nurseId;

  const CustomFloatingActionButton({
    super.key,
    required this.nurseId,
  });

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
            icon: Icons.medication,
            label: 'Record Medication',
            onTap: () {
              Navigator.pop(context);
              _selectPatientForMedication(context);
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

  void _selectPatientForMedication(BuildContext context) {
    showDialog<Patient?>(
      context: context,
      builder: (context) => _buildPatientSelectionDialog(
        context,
        onPatientSelected: (patient) {
          if (patient != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordMedicationScreen(
                  patientId: patient.id,
                  patientName: patient.name,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _selectPatientForVitals(BuildContext context) {
    showDialog<Patient?>(
      context: context,
      builder: (context) => _buildPatientSelectionDialog(
        context,
        onPatientSelected: (patient) {
          if (patient != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecordVitalsScreen(
                  patientId: patient.id,
                  patientName: patient.name,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPatientSelectionDialog(
    BuildContext context, {
    required Function(Patient?) onPatientSelected,
  }) {
    return AlertDialog(
      title: const Text('Select Patient'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('patients')
              .where('assignedNurseId', isEqualTo: nurseId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Error loading patients'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _selectPatientForVitals(context);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No assigned patients found'));
            }

            final patients = snapshot.data!.docs.map((doc) {
              return Patient.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList()
              ..sort((a, b) => a.name.compareTo(b.name));

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
                    onTap: () {
                      Navigator.pop(context);
                      onPatientSelected(patient);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onPatientSelected(null);
          },
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
