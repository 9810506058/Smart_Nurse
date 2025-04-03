import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final String room;
  final String status; // 'stable', 'critical', 'recovering'
  final String? assignedNurseId;
  final DateTime? assignedAt;
  final int roomNumber;
  final int bedNumber;
  final String notes;
  final List<String> conditions;
  final List<String> allergies;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.name,
    required this.room,
    required this.status,
    this.assignedNurseId,
    this.assignedAt,
    required this.roomNumber,
    required this.bedNumber,
    required this.notes,
    this.conditions = const [],
    this.allergies = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromMap(Map<String, dynamic> map, String id) {
    return Patient(
      id: id,
      name: map['name'] ?? '',
      room: map['room'] ?? '',
      status: map['status'] ?? 'active',
      assignedNurseId: map['assignedNurseId'],
      assignedAt: (map['assignedAt'] as Timestamp?)?.toDate(),
      roomNumber: int.tryParse(map['roomNumber']?.toString() ?? '') ?? 0,
      bedNumber: int.tryParse(map['bedNumber']?.toString() ?? '') ?? 0,
      notes: map['notes'] ?? '',
      conditions: List<String>.from(map['conditions'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'room': room,
      'status': status,
      'assignedNurseId': assignedNurseId,
      'assignedAt': assignedAt,
      'roomNumber': roomNumber,
      'bedNumber': bedNumber,
      'notes': notes,
      'conditions': conditions,
      'allergies': allergies,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Patient copyWith({
    String? name,
    String? room,
    String? status,
    String? assignedNurseId,
    DateTime? assignedAt,
    int? roomNumber,
    int? bedNumber,
    String? notes,
    List<String>? conditions,
    List<String>? allergies,
  }) {
    return Patient(
      id: this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      status: status ?? this.status,
      assignedNurseId: assignedNurseId ?? this.assignedNurseId,
      assignedAt: assignedAt ?? this.assignedAt,
      roomNumber: roomNumber ?? this.roomNumber,
      bedNumber: bedNumber ?? this.bedNumber,
      notes: notes ?? this.notes,
      conditions: conditions ?? this.conditions,
      allergies: allergies ?? this.allergies,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
