class Nurse {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Nurse({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Nurse.fromMap(Map<String, dynamic> data, String id) {
    return Nurse(
      id: id,
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }
}
