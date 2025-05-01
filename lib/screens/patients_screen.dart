import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';
import '../widgets/patient_list_item.dart';
import 'patient_details_screen.dart';
import 'add_patient_screen.dart';

class PatientsScreen extends StatelessWidget {
  final String nurseId;

  const PatientsScreen({
    Key? key,
    required this.nurseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return const Center(child: Text('No patients found'));
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
              return PatientListItem(
                patient: patient,
                onTap: () => _handlePatientTap(context, patient),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPatientScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handlePatientTap(BuildContext context, Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(patient: patient),
      ),
    );
  }
}
