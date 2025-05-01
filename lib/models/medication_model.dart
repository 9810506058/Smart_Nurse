import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String patientId;
  final DateTime dueTime;
  final bool isAdministered;
  final DateTime? administeredAt; // Optional field
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.patientId,
    required this.dueTime,
    required this.isAdministered,
    this.administeredAt, // Nullable
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
      administeredAt: (data['administeredAt'] as Timestamp?)?.toDate(), // Handle null
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final data = {
      'name': name,
      'dosage': dosage,
      'patientId': patientId,
      'dueTime': dueTime,
      'isAdministered': isAdministered,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };

    // Only include administeredAt if it's not null
    if (administeredAt != null) {
      data['administeredAt'] = administeredAt as Object;
    }

    return data;
  }
}