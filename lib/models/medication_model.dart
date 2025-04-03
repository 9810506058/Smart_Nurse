import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String patientId;
// Link to a patient
  final DateTime dueTime;
  final bool isAdministered;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.patientId,
    required this.dueTime,
    required this.isAdministered,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromMap(Map<String, dynamic> data, String id) {
    return Medication(
      id: id,
      name: data['name'] ?? 'Unknown Medication',
      dosage: data['dosage'] ?? 'No dosage specified',
      patientId: data['patientId'] ?? '',
      dueTime: (data['dueTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAdministered: data['isAdministered'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
