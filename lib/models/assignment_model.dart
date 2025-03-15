class Assignment {
  final String id;
  final String nurseId; // ID of the nurse assigned
  final String patientId; // ID of the patient assigned
  final String? taskId; // ID of the task assigned (optional)
  final String assignedBy; // ID of the nurse supervisor who made the assignment
  final DateTime assignedAt; // Timestamp when the assignment was made
  final DateTime createdAt; // Timestamp when the assignment was added
  final DateTime updatedAt; // Timestamp when the assignment was last updated

  Assignment({
    required this.id,
    required this.nurseId,
    required this.patientId,
    this.taskId,
    required this.assignedBy,
    required this.assignedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Assignment.fromMap(Map<String, dynamic> data, String id) {
    return Assignment(
      id: id,
      nurseId: data['nurseId'],
      patientId: data['patientId'],
      taskId: data['taskId'],
      assignedBy: data['assignedBy'],
      assignedAt: data['assignedAt'].toDate(),
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nurseId': nurseId,
      'patientId': patientId,
      'taskId': taskId,
      'assignedBy': assignedBy,
      'assignedAt': assignedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
