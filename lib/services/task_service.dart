import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a task
  Future<String> addTask(Task task) async {
    final ref = await _firestore.collection('tasks').add({
      'title': task.title,
      'description': task.description,
      'patientId': task.patientId,
      'dueDate': task.dueDate,
      'isCompleted': task.isCompleted,
      'createdAt': task.createdAt,
      'updatedAt': task.updatedAt,
    });
    return ref.id;
  }

  // Fetch tasks for a specific patient
  Stream<List<Task>> getTasksForPatient(String patientId) {
    return _firestore
        .collection('tasks')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Task.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
