import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnurse/screens/add_patient_screen.dart';
import 'package:smartnurse/screens/add_task_screen.dart';
import 'package:smartnurse/screens/record_medication_screen.dart';
import 'package:smartnurse/screens/record_vitals_screen.dart';
import '../models/patient_model.dart'; // Import the Patient model

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Add Patient'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPatientScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_task),
                    title: const Text('Add Task'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.medication_outlined),
                    title: const Text('Record Medication'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecordMedicationScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.monitor_heart),
                    title: const Text('Record Vitals'),
                    onTap: () {
                      Navigator.pop(context);
                      _selectPatient(context); // Open patient selection dialog
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }

  // Function to show patient selection dialog
  void _selectPatient(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a patient'),
          content: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('patients').get(),
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
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return ListTile(
                      title: Text(patient.name),
                      subtitle: Text('Room ${patient.roomNumber}'),
                      onTap: () {
                        Navigator.pop(context); // Close the dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecordVitalsScreen(patientId: patient.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
