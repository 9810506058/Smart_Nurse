import 'package:flutter/material.dart';
import '../screens/medications_screen.dart';
import '../screens/patients_screen.dart';
import '../screens/tasks_screen.dart';

class DashboardNavigationButtons extends StatelessWidget {
  final String nurseId;

  const DashboardNavigationButtons({
    Key? key,
    required this.nurseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildNavigationCard(
          context,
          icon: Icons.people,
          title: 'Patients',
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientsScreen(nurseId: nurseId),
            ),
          ),
        ),
        _buildNavigationCard(
          context,
          icon: Icons.medication,
          title: 'Medications',
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicationsScreen(),
            ),
          ),
        ),
        _buildNavigationCard(
          context,
          icon: Icons.task_alt,
          title: 'Tasks',
          color: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TasksScreen(nurseId: nurseId),
            ),
          ),
        ),
        _buildNavigationCard(
          context,
          icon: Icons.warning,
          title: 'Critical',
          color: Colors.red,
          onTap: () => _scrollToSection(context, 'critical'),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToSection(BuildContext context, String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scrolling to $section section...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
