import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnurse/screens/add_patient_screen.dart';
import '../models/patient_model.dart'; // Import the Patient model
import '../widgets/patient_list_item.dart'; // Import the PatientListItem widget

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Handle search functionality
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('patients').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No patients found'));
            }

            // Convert Firestore documents to Patient objects
            final patients = snapshot.data!.docs.map((doc) {
              return Patient.fromMap(
                  doc.data() as Map<String, dynamic>, doc.id);
            }).toList();

            // Display the list of patients
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return PatientListItem(
                  initials: patient.name.substring(0, 2).toUpperCase(),
                  backgroundColor: _getColorForInitials(patient.name),
                  name: patient.name,
                  details:
                      'Room ${patient.roomNumber} • ${patient.status} • ${patient.notes}',
                  patientId: patient.id, // Pass the patientId
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add patient screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPatientScreen()),
          );
        },
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
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
