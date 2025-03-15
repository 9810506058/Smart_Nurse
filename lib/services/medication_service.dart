import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a medication
  Future<String> addMedication(Medication medication) async {
    final ref = await _firestore.collection('medications').add({
      'name': medication.name,
      'dosage': medication.dosage,
      'patientId': medication.patientId,
      'dueTime': medication.dueTime,
      'isAdministered': medication.isAdministered,
      'createdAt': medication.createdAt,
      'updatedAt': medication.updatedAt,
    });
    return ref.id;
  }

  // Fetch medications for a specific patient
  Stream<List<Medication>> getMedicationsForPatient(String patientId) {
    return _firestore
        .collection('medications')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Medication.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
