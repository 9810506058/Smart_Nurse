import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'patients_screen.dart';
import 'tasks_screen.dart';
import 'medications_screen.dart';
import 'profile_screen.dart';
import '../widgets/floating_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const PatientsScreen(),
    const TasksScreen(),
    const MedicationsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Nurse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Meds'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: const CustomFloatingActionButton(),
    );
  }
}
