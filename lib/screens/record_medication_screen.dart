import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordMedicationScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const RecordMedicationScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  _RecordMedicationScreenState createState() => _RecordMedicationScreenState();
}

class _RecordMedicationScreenState extends State<RecordMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _routeController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _scheduledTime = DateTime.now();

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection(
                'medications') // Save directly to the medications collection
            .add({
          'name': _medicationController.text,
          'dosage': _dosageController.text,
          'patientId': widget.patientId,
          'dueTime': _scheduledTime,
          'isAdministered': false, // Default to false
          'administeredAt': null, // Not administered yet
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medication recorded successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to record medication: $e')),
          );
        }
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledTime),
    );
    if (picked != null && picked != TimeOfDay.fromDateTime(_scheduledTime)) {
      setState(() {
        _scheduledTime = DateTime(
          _scheduledTime.year,
          _scheduledTime.month,
          _scheduledTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Medication - ${widget.patientName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _medicationController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter frequency';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: 'Route',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter route';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Scheduled Time'),
                subtitle: Text(
                  '${_scheduledTime.hour.toString().padLeft(2, '0')}:${_scheduledTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveMedication,
                  child: const Text('Save Medication'),
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
    _medicationController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _routeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
