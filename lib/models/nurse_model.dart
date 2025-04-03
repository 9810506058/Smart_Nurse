import 'package:cloud_firestore/cloud_firestore.dart';

class Nurse {
  final String id;
  final String userId;
  final String name;
  final String role;
  final String shift;
  final List<String> specializations;
  final int currentWorkload;
  final int maxWorkload;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Nurse({
    required this.id,
    required this.userId,
    required this.name,
    required this.role,
    required this.shift,
    required this.specializations,
    required this.currentWorkload,
    required this.maxWorkload,
    this.createdAt,
    this.updatedAt,
  });

  factory Nurse.fromMap(Map<String, dynamic> map) {
    return Nurse(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'nurse',
      shift: map['shift'] ?? 'day',
      specializations: List<String>.from(map['specializations'] ?? []),
      currentWorkload: map['currentWorkload'] ?? 0,
      maxWorkload: map['maxWorkload'] ?? 10,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'role': role,
      'shift': shift,
      'specializations': specializations,
      'currentWorkload': currentWorkload,
      'maxWorkload': maxWorkload,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Nurse copyWith({
    String? id,
    String? userId,
    String? name,
    String? role,
    String? shift,
    List<String>? specializations,
    int? currentWorkload,
    int? maxWorkload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Nurse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      shift: shift ?? this.shift,
      specializations: specializations ?? this.specializations,
      currentWorkload: currentWorkload ?? this.currentWorkload,
      maxWorkload: maxWorkload ?? this.maxWorkload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
