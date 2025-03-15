import 'package:flutter/material.dart';
import '../widgets/medication_list_item.dart'; // Reusable medication list item widget

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search functionality
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          MedicationListItem(
            icon: Icons.medication,
            iconColor: Colors.purple,
            title: 'Antibiotics - Emily Wilson',
            subtitle: 'Room 105 • Due at 2:30 PM',
          ),
          SizedBox(height: 8),
          MedicationListItem(
            icon: Icons.medication,
            iconColor: Colors.blue,
            title: 'Pain medication - John Smith',
            subtitle: 'Room 203 • Due at 3:00 PM',
          ),
          SizedBox(height: 8),
          MedicationListItem(
            icon: Icons.medication,
            iconColor: Colors.green,
            title: 'IV Fluids - Mary Robinson',
            subtitle: 'Room 157 • Check and refill',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to record medication screen
        },
        child: const Icon(Icons.medication_outlined),
      ),
    );
  }
}
