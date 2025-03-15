class Medication {
  final String id;
  final String name;
  final String dosage;
  final String patientId; // Link to a patient
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
      name: data['name'],
      dosage: data['dosage'],
      patientId: data['patientId'],
      dueTime: data['dueTime'].toDate(),
      isAdministered: data['isAdministered'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }
}
