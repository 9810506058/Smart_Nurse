import 'package:flutter/material.dart';
import '../models/patient_model.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailsScreen({
    Key? key,
    required this.patient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              'Basic Information',
              [
                _buildInfoRow('Room', patient.room),
                _buildInfoRow('Status', patient.status),
                _buildInfoRow('Room Number', patient.roomNumber.toString()),
                _buildInfoRow('Bed Number', patient.bedNumber.toString()),
              ],
            ),
            const SizedBox(height: 16),
            if (patient.conditions.isNotEmpty)
              _buildInfoCard(
                context,
                'Conditions',
                patient.conditions
                    .map((condition) => _buildInfoRow('', condition))
                    .toList(),
              ),
            const SizedBox(height: 16),
            if (patient.allergies.isNotEmpty)
              _buildInfoCard(
                context,
                'Allergies',
                patient.allergies
                    .map((allergy) => _buildInfoRow('', allergy))
                    .toList(),
              ),
            const SizedBox(height: 16),
            if (patient.notes.isNotEmpty)
              _buildInfoCard(
                context,
                'Notes',
                [_buildInfoRow('', patient.notes)],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
