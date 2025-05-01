import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nurse_model.dart';

class ProfileScreen extends StatelessWidget {
  final String nurseId;

  const ProfileScreen({
    Key? key,
    required this.nurseId,
  }) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('nurses')
            .doc(nurseId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No profile data found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final user = FirebaseAuth.instance.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      data['name']?[0].toUpperCase() ?? 'N',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileCard(
                  context,
                  title: 'Personal Information',
                  children: [
                    _buildInfoRow('Name', data['name'] ?? 'Not set'),
                    _buildInfoRow('Email', user?.email ?? 'Not set'),
                    _buildInfoRow('Phone', data['phone'] ?? 'Not set'),
                    _buildInfoRow('Role', data['role'] ?? 'Not set'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProfileCard(
                  context,
                  title: 'Work Information',
                  children: [
                    _buildInfoRow(
                        'Department', data['department'] ?? 'Not set'),
                    _buildInfoRow('Shift', data['shift'] ?? 'Not set'),
                    _buildInfoRow(
                        'Experience', '${data['experience'] ?? '0'} years'),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
