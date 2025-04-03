import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

class PatientService {
  final CollectionReference _patientsCollection =
      FirebaseFirestore.instance.collection('patients');

  // Get all patients
  Stream<List<Patient>> getPatients() {
    return _patientsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get patients by nurse
  Stream<List<Patient>> getPatientsByNurse(String nurseId) {
    return _patientsCollection
        .where('assignedNurseId', isEqualTo: nurseId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get single patient
  Future<Patient?> getPatient(String patientId) async {
    final doc = await _patientsCollection.doc(patientId).get();
    if (!doc.exists) return null;
    return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Create new patient
  Future<String> createPatient(Map<String, dynamic> data) async {
    final docRef = await _patientsCollection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Update patient
  Future<void> updatePatient(String patientId, Map<String, dynamic> data) async {
    await _patientsCollection.doc(patientId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete patient
  Future<void> deletePatient(String patientId) async {
    await _patientsCollection.doc(patientId).delete();
  }

  // Assign patient to nurse
  Future<void> assignPatientToNurse(String patientId, String nurseId) async {
    await _patientsCollection.doc(patientId).update({
      'assignedNurseId': nurseId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get patients by status
  Stream<List<Patient>> getPatientsByStatus(String status) {
    return _patientsCollection
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get patients by room
  Stream<List<Patient>> getPatientsByRoom(int roomNumber) {
    return _patientsCollection
        .where('roomNumber', isEqualTo: roomNumber)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Patient.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
