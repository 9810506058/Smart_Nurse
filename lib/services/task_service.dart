import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  // Get all tasks
  Stream<List<Task>> getTasks() {
    return _tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    }).handleError((e) {
      print('Error getting tasks: $e');
    });
  }

  // Get tasks assigned to a specific nurse
  Stream<List<Task>> getTasksByNurse(String nurseId) {
    return _tasksCollection
        .where('assignedNurseId', isEqualTo: nurseId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    }).handleError((e) {
      print('Error getting tasks for nurse $nurseId: $e');
    });
  }

  // Create a new task
  Future<void> createTask({
    required String title,
    required String description,
    required String priority,
    required List<String> requiredSpecializations,
  }) async {
    try {
      final task = {
        'title': title,
        'description': description,
        'priority': priority,
        'status': 'pending',
        'requiredSpecializations': requiredSpecializations,
        'assignedNurseId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _tasksCollection.add(task);
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  // Update task status
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _tasksCollection.doc(taskId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating task status for task $taskId: $e');
      rethrow;
    }
  }

  // Assign task to nurse
  Future<void> assignTask(String taskId, String nurseId) async {
    try {
      await _tasksCollection.doc(taskId).update({
        'assignedNurseId': nurseId,
        'status': 'inProgress',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error assigning task $taskId to nurse $nurseId: $e');
      rethrow;
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      print('Error deleting task $taskId: $e');
      rethrow;
    }
  }
}
