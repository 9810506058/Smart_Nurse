class Vitals {
  final String id;
  final String patientId; // Link to the patient
  final String bloodPressure;
  final String heartRate;
  final String temperature;
  final String weight;
  final DateTime createdAt;

  Vitals({
    required this.id,
    required this.patientId,
    required this.bloodPressure,
    required this.heartRate,
    required this.temperature,
    required this.weight,
    required this.createdAt,
  });

  factory Vitals.fromMap(Map<String, dynamic> data, String id) {
    return Vitals(
      id: id,
      patientId: data['patientId'],
      bloodPressure: data['bloodPressure'],
      heartRate: data['heartRate'],
      temperature: data['temperature'],
      weight: data['weight'],
      createdAt: data['createdAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
      'temperature': temperature,
      'weight': weight,
      'createdAt': createdAt,
    };
  }
}
