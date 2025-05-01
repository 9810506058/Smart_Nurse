import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';
import '../models/vitals_model.dart';
import '../models/medication_model.dart';

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
            const SizedBox(height: 24),
            _buildVitalsSection(context),
            const SizedBox(height: 24),
            _buildMedicationsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildVitalsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vital Signs History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            _buildTimeRangeSelector(context),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vitals')
              .where('patientId', isEqualTo: patient.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No vitals recorded yet');
            }

            final vitalsByDate = <DateTime, List<Vitals>>{};
            // Convert documents to Vitals objects and sort by createdAt
            final sortedVitals = snapshot.data!.docs.map((doc) {
              return Vitals.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            }).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            for (var vital in sortedVitals) {
              final date = DateTime(
                vital.createdAt.year,
                vital.createdAt.month,
                vital.createdAt.day,
              );
              vitalsByDate.putIfAbsent(date, () => []).add(vital);
            }

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vitalsByDate.length,
                itemBuilder: (context, index) {
                  final date = vitalsByDate.keys.elementAt(index);
                  final vitalsForDate = vitalsByDate[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _formatDate(date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ...vitalsForDate.map((vital) => _buildVitalCard(vital)),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // TODO: Implement time range filtering
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'today',
          child: Text('Today'),
        ),
        const PopupMenuItem(
          value: 'week',
          child: Text('This Week'),
        ),
        const PopupMenuItem(
          value: 'month',
          child: Text('This Month'),
        ),
        const PopupMenuItem(
          value: 'all',
          child: Text('All Time'),
        ),
      ],
    );
  }

  Widget _buildVitalCard(Vitals vital) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTime(vital.createdAt),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildVitalRow('Blood Pressure', vital.bloodPressure),
            _buildVitalRow('Heart Rate', '${vital.heartRate} bpm'),
            _buildVitalRow('Temperature', '${vital.temperature}°C'),
            _buildVitalRow('Weight', '${vital.weight} kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Medications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('medications')
              .where('patientId', isEqualTo: patient.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No medications administered yet');
            }

            // Convert documents to Medication objects and sort by updatedAt
            final medications = snapshot.data!.docs.map((doc) {
              return Medication.fromMap(
                  doc.data() as Map<String, dynamic>, doc.id);
            }).toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

            final recentMedications = medications.take(5).toList();

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentMedications.length,
                itemBuilder: (context, index) {
                  final medication = recentMedications[index];

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Due on ${_formatDateTime(medication.dueTime)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: medication.isAdministered
                                    ? Colors.green[50]
                                    : Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: medication.isAdministered
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              child: Text(
                                medication.isAdministered
                                    ? 'Administered'
                                    : 'Pending',
                                style: TextStyle(
                                  color: medication.isAdministered
                                      ? Colors.green[900]
                                      : Colors.orange[900],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildMedicationRow('Name', medication.name),
                        _buildMedicationRow('Dosage', medication.dosage),
                        Text(
                          'Last updated: ${_formatDateTime(medication.updatedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVitalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
