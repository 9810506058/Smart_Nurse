import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nurse_model.dart';

class NurseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a nurse
  Future<String> addNurse(Nurse nurse) async {
    final ref = await _firestore.collection('nurses').add({
      'name': nurse.name,
      'email': nurse.email,
      'phone': nurse.phone,
      'createdAt': nurse.createdAt,
      'updatedAt': nurse.updatedAt,
    });
    return ref.id;
  }

  // Fetch all nurses
  Stream<List<Nurse>> getNurses() {
    return _firestore.collection('nurses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Nurse.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
