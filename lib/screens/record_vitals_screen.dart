import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vitals_model.dart';

class RecordVitalsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const RecordVitalsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  _RecordVitalsScreenState createState() => _RecordVitalsScreenState();
}

class _RecordVitalsScreenState extends State<RecordVitalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloodPressureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _weightController = TextEditingController();

  Future<void> _saveVitals() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new vitals record in the main vitals collection
        await FirebaseFirestore.instance.collection('vitals').add({
          'patientId': widget.patientId,
          'bloodPressure': _bloodPressureController.text,
          'heartRate': _heartRateController.text,
          'temperature': _temperatureController.text,
          'weight': _weightController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vitals recorded successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to record vitals: $e')),
        );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Vitals - ${widget.patientName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _bloodPressureController,
                decoration: const InputDecoration(
                  labelText: 'Blood Pressure',
                  hintText: 'e.g., 120/80',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter blood pressure';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heartRateController,
                decoration: const InputDecoration(
                  labelText: 'Heart Rate (bpm)',
                  hintText: 'e.g., 72',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter heart rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _temperatureController,
                decoration: const InputDecoration(
                  labelText: 'Temperature (°C)',
                  hintText: 'e.g., 37.0',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter temperature';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'e.g., 70',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                onPressed: _saveVitals,
                  child: const Text('Save Vitals'),
                ),
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
    _temperatureController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
