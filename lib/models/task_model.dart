import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String? assignedNurseId;
  final String status;
  final String priority;
  final List<String> requiredSpecializations;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.assignedNurseId,
    required this.status,
    required this.priority,
    required this.requiredSpecializations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    final timestamp = map['createdAt'] as Timestamp?;
    final updateTimestamp = map['updatedAt'] as Timestamp?;

    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      assignedNurseId: map['assignedNurseId'],
      status: map['status'] ?? 'pending',
      priority: map['priority'] ?? 'medium',
      requiredSpecializations:
          List<String>.from(map['requiredSpecializations'] ?? []),
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      updatedAt: updateTimestamp?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedNurseId': assignedNurseId,
      'status': status,
      'priority': priority,
      'requiredSpecializations': requiredSpecializations,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Task copyWith({
    String? title,
    String? description,
    String? assignedNurseId,
    String? status,
    String? priority,
    List<String>? requiredSpecializations,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedNurseId: assignedNurseId ?? this.assignedNurseId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      requiredSpecializations:
          requiredSpecializations ?? this.requiredSpecializations,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
