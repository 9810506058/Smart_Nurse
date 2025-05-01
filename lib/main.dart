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
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => ProfileScreen(
              nurseId: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/supervisor_dashboard': (context) => const SupervisorDashboard(),
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String?>(
          future: _getUserRole(snapshot.data!.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${roleSnapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final role = roleSnapshot.data;
            if (role == null) {
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }

            if (role == 'supervisor') {
              return const SupervisorDashboard();
            } else {
              return DashboardScreenUpdated(
                nurseId: snapshot.data!.uid,
                nurseName: snapshot.data!.displayName ?? '',
              );
            }
          },
        );
      },
    );
  }

  Future<String?> _getUserRole(String userId) async {
    try {
      final nurseService = NurseService();
      final nurse = await nurseService.getNurseByUserId(userId);
      return nurse?.role;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }
}
