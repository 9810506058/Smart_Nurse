import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';
import '../widgets/medication_list_item.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medications')
            .where('isAdministered', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No medications found'));
          }

          final now = DateTime.now();
          final medications = snapshot.data!.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Medication.fromMap(data, doc.id);
              })
              .where((medication) =>
                  !medication.isAdministered &&
                  medication.dueTime
                      .isBefore(now.add(const Duration(hours: 24))))
              .toList()
            ..sort((a, b) => a.dueTime.compareTo(b.dueTime));

          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return MedicationListItem(
                icon: Icons.medication,
                iconColor: Theme.of(context).colorScheme.primary,
                title: medication.name,
                subtitle: 'Due at ${_formatTime(medication.dueTime)}',
                medication: medication,
                onTap: () => _handleMedicationTap(context, medication),
                onAdministeredChanged: (value) =>
                    _updateMedicationStatus(medication, value),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add medication functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Add medication functionality coming soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _handleMedicationTap(BuildContext context, Medication medication) {
    // TODO: Implement medication details view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${medication.name}')),
    );
  }

  Future<void> _updateMedicationStatus(
      Medication medication, bool isAdministered) async {
    try {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(medication.id)
          .update({'isAdministered': isAdministered});
    } catch (e) {
      debugPrint('Error updating medication status: $e');
    }
  }
}
