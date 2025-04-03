import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nurse_model.dart';

class NurseService {
  final CollectionReference _nursesCollection =
      FirebaseFirestore.instance.collection('nurses');

  // Create a new nurse
  Future<void> createNurse({
    required String userId,
    required String name,
    required String role,
    required String shift,
    required List<String> specializations,
  }) async {
    try {
      await _nursesCollection.doc(userId).set({
        'userId': userId,
        'name': name,
        'role': role,
        'shift': shift,
        'specializations': specializations,
        'currentWorkload': 0,
        'maxWorkload': 10,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating nurse: $e');
      rethrow;
    }
  }

  // Get nurse by user ID
  Future<Nurse?> getNurseByUserId(String userId) async {
    try {
      final doc = await _nursesCollection.doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Nurse.fromMap(data);
    } catch (e) {
      print('Error getting nurse by userId: $e');
      return null;
    }
  }

  // Get nurse role
  Future<String?> getNurseRole(String userId) async {
    try {
      final nurse = await getNurseByUserId(userId);
      return nurse?.role;
    } catch (e) {
      print('Error getting nurse role: $e');
      return null;
    }
  }

  // Get all nurses
  Stream<List<Nurse>> getNurses() {
    return _nursesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Nurse.fromMap(data);
      }).toList();
    }).handleError((e) {
      print('Error getting nurses: $e');
    });
  }

  // Get nurses by shift
  Stream<List<Nurse>> getNursesByShift(String shift) {
    return _nursesCollection
        .where('shift', isEqualTo: shift)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Nurse.fromMap(data);
      }).toList();
    }).handleError((e) {
      print('Error getting nurses by shift: $e');
    });
  }

  // Get available nurses (not at max workload)
  Stream<List<Nurse>> getAvailableNurses() {
    return _nursesCollection
        .where('role', isEqualTo: 'nurse')
        .where('currentWorkload', isLessThan: 10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Nurse.fromMap(data);
      }).toList();
    }).handleError((e) {
      print('Error getting available nurses: $e');
    });
  }

  // Update nurse workload
  Future<void> updateNurseWorkload(String nurseId, int workload) async {
    try {
      await _nursesCollection.doc(nurseId).update({
        'currentWorkload': workload,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating nurse workload: $e');
      rethrow;
    }
  }

  // Update nurse shift
  Future<void> updateNurseShift(String nurseId, String shift) async {
    try {
      await _nursesCollection.doc(nurseId).update({
        'shift': shift,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating nurse shift: $e');
      rethrow;
    }
  }

  // Update nurse specializations
  Future<void> updateNurseSpecializations(
      String nurseId, List<String> specializations) async {
    try {
      await _nursesCollection.doc(nurseId).update({
        'specializations': specializations,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating nurse specializations: $e');
      rethrow;
    }
  }

  // Delete nurse
  Future<void> deleteNurse(String nurseId) async {
    try {
      await _nursesCollection.doc(nurseId).delete();
    } catch (e) {
      print('Error deleting nurse: $e');
      rethrow;
    }
  }

  // Get available specializations
  Stream<List<String>> getAvailableSpecializations() {
    return _nursesCollection.snapshots().map((snapshot) {
      final specializations = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final nurseSpecializations =
            List<String>.from(data['specializations'] ?? []);
        specializations.addAll(nurseSpecializations);
      }
      return specializations.toList();
    }).handleError((e) {
      print('Error getting available specializations: $e');
    });
  }

  // Create sample nurses for testing
  Future<void> createSampleNurses() async {
    try {
      final sampleNurses = [
        {
          'userId': 'nurse1',
          'name': 'John Doe',
          'role': 'nurse',
          'shift': 'morning',
          'specializations': ['General Care', 'Critical Care'],
          'currentWorkload': 2,
          'maxWorkload': 10,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'userId': 'nurse2',
          'name': 'Jane Smith',
          'role': 'nurse',
          'shift': 'evening',
          'specializations': ['Pediatrics', 'Emergency Care'],
          'currentWorkload': 5,
          'maxWorkload': 10,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'userId': 'nurse3',
          'name': 'Mike Johnson',
          'role': 'nurse',
          'shift': 'night',
          'specializations': ['Surgery', 'Intensive Care'],
          'currentWorkload': 8,
          'maxWorkload': 10,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      final batch = FirebaseFirestore.instance.batch();

      for (final nurse in sampleNurses) {
        final docRef = _nursesCollection.doc(nurse['userId'] as String);
        batch.set(docRef, nurse);
      }

      await batch.commit();
    } catch (e) {
      print('Error creating sample nurses: $e');
      rethrow;
    }
  }
}
