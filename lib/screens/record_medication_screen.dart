import 'package:flutter/material.dart';

class RecordMedicationScreen extends StatelessWidget {
  const RecordMedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Record Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Medication Name'),
            ),
            TextField(decoration: InputDecoration(labelText: 'Dosage')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logic to save the medication
              },
              child: Text('Save Medication'),
            ),
          ],
        ),
      ),
    );
  }
}
