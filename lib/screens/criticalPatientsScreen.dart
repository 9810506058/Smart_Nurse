import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/patient_model.dart';
import '../widgets/patient_list_item.dart';

class CriticalPatientsScreen extends StatelessWidget {
  final String nurseId;

  const CriticalPatientsScreen({Key? key, required this.nurseId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Critical Patients')),
      body: _buildCriticalPatientsList(context),
    );
  }

  Widget _buildCriticalPatientsList(BuildContext context) {
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
          return const Center(child: Text('No critical patients.'));
        }

        final patients = snapshot.data!.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Patient.fromMap(data, doc.id);
            })
            .where((patient) => patient.status.toLowerCase() == 'critical')
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        if (patients.isEmpty) {
          return const Center(child: Text('No critical patients.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return PatientListItem(
              patient: patient,
              onTap: () => _handlePatientTap(context, patient),
            );
          },
          separatorBuilder: (context, index) =>
              const Divider(height: 1, thickness: 1),
        );
      },
    );
  }

  void _handlePatientTap(BuildContext context, Patient patient) {
    // Navigate to patient details or handle as needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tapped on ${patient.name}')),
    );
  }
}
