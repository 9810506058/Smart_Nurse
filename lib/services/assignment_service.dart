import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add an assignment
  Future<String> addAssignment(Assignment assignment) async {
    final ref = await _firestore
        .collection('assignments')
        .add(assignment.toMap());
    return ref.id;
  }

  // Fetch all assignments
  Stream<List<Assignment>> getAssignments() {
    return _firestore.collection('assignments').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Assignment.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Fetch assignments for a specific nurse
  Stream<List<Assignment>> getAssignmentsForNurse(String nurseId) {
    return _firestore
        .collection('assignments')
        .where('nurseId', isEqualTo: nurseId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Assignment.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Fetch assignments for a specific patient
  Stream<List<Assignment>> getAssignmentsForPatient(String patientId) {
    return _firestore
        .collection('assignments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Assignment.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Update an assignment
  Future<void> updateAssignment(Assignment assignment) async {
    await _firestore
        .collection('assignments')
        .doc(assignment.id)
        .update(assignment.toMap());
  }

  // Delete an assignment
  Future<void> deleteAssignment(String assignmentId) async {
    await _firestore.collection('assignments').doc(assignmentId).delete();
  }
}
