import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';
import '../widgets/medication_list_item.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  _MedicationsScreenState createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Unadministered'),
            Tab(text: 'Administered'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMedicationList(false), // Unadministered medications
          _buildMedicationList(true),  // Administered medications
        ],
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

  Widget _buildMedicationList(bool isAdministered) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('medications')
          .where('isAdministered', isEqualTo: isAdministered)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(isAdministered
                ? 'No administered medications found'
                : 'No unadministered medications found'),
          );
        }

        final medications = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Medication.fromMap(data, doc.id);
        }).toList();

        return ListView.builder(
          itemCount: medications.length,
          itemBuilder: (context, index) {
            final medication = medications[index];
            return MedicationListItem(
              icon: Icons.medication,
              iconColor: Theme.of(context).colorScheme.primary,
              title: medication.name,
              subtitle: isAdministered
                  ? 'Administered at ${_formatTime(medication.administeredAt)}'
                  : 'Due at ${_formatTime(medication.dueTime)}',
              medication: medication,
              onTap: () => _handleMedicationTap(context, medication),
              onAdministeredChanged: isAdministered
                  ? (value) {} // No-op function for administered medications
                  : (value) {
                      _updateMedicationStatus(medication, value);
                    },
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'N/A';
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
          .update({
        'isAdministered': isAdministered,
        'administeredAt': isAdministered ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating medication status: $e');
    }
  }
}