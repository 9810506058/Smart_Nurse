import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart'; // Import the Patient model

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _statusController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Parse roomNumber as an integer
        final roomNumber = int.tryParse(_roomNumberController.text) ?? 0;

        // Save patient data to Firestore
        await FirebaseFirestore.instance.collection('patients').add({
          'name': _nameController.text,
          'roomNumber': roomNumber,
          'status': _statusController.text.isNotEmpty
              ? _statusController.text
              : 'Admitted', // Default status
          'notes': _notesController.text, // Notes (optional)
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient saved successfully!')),
        );

        // Clear the form
        _nameController.clear();
        _roomNumberController.clear();
        _statusController.clear();
        _notesController.clear();
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save patient: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Patient')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Patient Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Patient Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the patient name';
                  }
                  return null;
                },
              ),

              // Room Number Field
              TextFormField(
                controller: _roomNumberController,
                decoration: InputDecoration(labelText: 'Room Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the room number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid room number';
                  }
                  return null;
                },
              ),

              // Status Field
              TextFormField(
                controller: _statusController,
                decoration: InputDecoration(
                    labelText: 'Status (e.g., Admitted, Post-surgery)'),
              ),

              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration:
                    InputDecoration(labelText: 'Notes (e.g., BP 150/90)'),
              ),

              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _savePatient,
                child: Text('Save Patient'),
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
    _roomNumberController.dispose();
    _statusController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
