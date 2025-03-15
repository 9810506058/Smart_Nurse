import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;

  final String status;
  final int roomNumber;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromMap(Map<String, dynamic> data, String id) {
    return Patient(
      id: id,
      name: data['name'] ?? '',
      roomNumber: int.tryParse(data['roomNumber']?.toString() ?? '') ?? 0,
      status: data['status'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
