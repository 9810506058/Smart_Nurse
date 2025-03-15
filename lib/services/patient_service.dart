import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

class PatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a patient
  Future<String> addPatient(Patient patient) async {
    final ref = await _firestore.collection('patients').add({
      'name': patient.name,
      'roomNumber': patient.roomNumber,
      'status': patient.status,
      'notes': patient.notes,
      'createdAt': patient.createdAt,
      'updatedAt': patient.updatedAt,
    });
    return ref.id;
  }

  // Fetch all patients
  Stream<List<Patient>> getPatients() {
    return _firestore.collection('patients').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Patient.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
