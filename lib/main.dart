import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartnurse/screens/dashboard_screen_updated.dart';
import 'screens/login_screen.dart';
import 'screens/nurse_dashboard.dart';
import 'screens/supervisor_dashboard.dart';
import 'screens/profile_screen.dart';
import 'services/nurse_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Sign out any existing user to show login screen
  await FirebaseAuth.instance.signOut();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Nurse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/profile': (context) => ProfileScreen(
              nurseId: ModalRoute.of(context)!.settings.arguments as String,
            ),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String?>(
          future: _getUserRole(snapshot.data!.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (roleSnapshot.hasError) {
              return Center(child: Text('Error: ${roleSnapshot.error}'));
            }

            final role = roleSnapshot.data;
            if (role == null) {
              return const LoginScreen();
            }

            if (role == 'supervisor') {
              return const SupervisorDashboard();
            } else {
              return DashboardScreenUpdated(
                  nurseId: snapshot.data!.uid,
                  nurseName: snapshot.data!.displayName ?? '');
            }
          },
        );
      },
    );
  }

  Future<String?> _getUserRole(String userId) async {
    final nurseService = NurseService();
    final nurse = await nurseService.getNurseByUserId(userId);
    return nurse?.role;
  }
}
