class Task {
  final String id;
  final String title;
  final String description;
  final String patientId; // Link to a patient
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.patientId,
    required this.dueDate,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromMap(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      title: data['title'],
      description: data['description'],
      patientId: data['patientId'],
      dueDate: data['dueDate'].toDate(),
      isCompleted: data['isCompleted'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }
}
