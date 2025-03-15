import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vitals_model.dart'; // Import the Vitals model

class RecordVitalsScreen extends StatefulWidget {
  final String patientId; // Add patientId parameter

  const RecordVitalsScreen({super.key, required this.patientId});

  @override
  _RecordVitalsScreenState createState() => _RecordVitalsScreenState();
}

class _RecordVitalsScreenState extends State<RecordVitalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloodPressureController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _heartRateController = TextEditingController();

  Future<void> _saveVitals() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Save vitals data to Firestore
        await FirebaseFirestore.instance.collection('vitals').add({
          'patientId': widget.patientId, // Use the patientId
          'bloodPressure': _bloodPressureController.text,
          'heartRate': _heartRateController.text,
          'weight': _weightController.text,
          'temperature': _temperatureController.text,
          'createdAt': DateTime.now(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vitals saved successfully!')),
        );

        // Clear the form
        _bloodPressureController.clear();
        _heartRateController.clear();
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save vitals: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Record Vitals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Blood Pressure Field
              TextFormField(
                controller: _bloodPressureController,
                decoration: InputDecoration(labelText: 'Blood Pressure'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the blood pressure';
                  }
                  return null;
                },
              ),

              // Heart Rate Field
              TextFormField(
                controller: _heartRateController,
                decoration: InputDecoration(labelText: 'Heart Rate'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the heart rate';
                  }
                  return null;
                },
              ),

              // Weight Field
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the weight';
                  }
                  return null;
                },
              ),

              // Temperature Field
              TextFormField(
                controller: _temperatureController,
                decoration: InputDecoration(labelText: 'Temperature'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the temperature';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _saveVitals,
                child: Text('Save Vitals'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }
}
