import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a medication
  Future<String> addMedication(Medication medication) async {
    final data = {
      'name': medication.name,
      'dosage': medication.dosage,
      'patientId': medication.patientId,
      'dueTime': medication.dueTime,
      'isAdministered': medication.isAdministered,
      'createdAt': medication.createdAt,
      'updatedAt': medication.updatedAt,
    };

    // Only include administeredAt if it's not null
    if (medication.administeredAt != null) {
      data['administeredAt'] = (medication.administeredAt != null
          ? Timestamp.fromDate(medication.administeredAt!)
          : null) as Object;
    }

    final ref = await _firestore.collection('medications').add(data);
    return ref.id;
  }

  // Update medication status
  Future<void> updateMedicationStatus(
      String medicationId, bool isAdministered) async {
    final data = {
      'isAdministered': isAdministered,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Only update administeredAt if the medication is administered
    if (isAdministered) {
      data['administeredAt'] = FieldValue.serverTimestamp();
    } else {
      data['administeredAt'] = (null as Object?)!;
    }

    await _firestore.collection('medications').doc(medicationId).update(data);
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
