import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/medication_model.dart';
import '../models/patient_model.dart';

class RecordMedicationScreen extends StatefulWidget {
  const RecordMedicationScreen({super.key});

  @override
  _RecordMedicationScreenState createState() => _RecordMedicationScreenState();
}

class _RecordMedicationScreenState extends State<RecordMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  DateTime? _dueTime;
  String? _selectedPatientId;
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('patients').get();
      setState(() {
        _patients = snapshot.docs.map((doc) {
          return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching patients: $e')),
      );
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due time')),
      );
      return;
    }
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    try {
      final medication = Medication(
        id: '',
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        patientId: _selectedPatientId!,
        dueTime: _dueTime!,
        isAdministered: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('medications').add({
        'name': medication.name,
        'dosage': medication.dosage,
        'patientId': medication.patientId,
        'dueTime': medication.dueTime,
        'isAdministered': medication.isAdministered,
        'createdAt': medication.createdAt,
        'updatedAt': medication.updatedAt,
      });

      await docRef.update({'id': docRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication saved successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save medication: $e')),
      );
    }
  }

  Future<void> _selectDueTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _dueTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the medication name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedPatientId,
                decoration: const InputDecoration(labelText: 'Select Patient'),
                items: _patients.isEmpty
                    ? [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No patients available'),
                        )
                      ]
                    : _patients.map((patient) {
                        return DropdownMenuItem(
                          value: patient.id,
                          child: Text(patient.name),
                        );
                      }).toList(),
                onChanged: _patients.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          _selectedPatientId = value;
                        });
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a patient';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(
                  _dueTime == null
                      ? 'Select Due Time'
                      : 'Due Time: ${DateFormat('hh:mm a').format(_dueTime!)}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectDueTime(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMedication,
                child: const Text('Save Medication'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}
