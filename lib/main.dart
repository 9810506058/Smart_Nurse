import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NursePatientManagementApp());
}

class NursePatientManagementApp extends StatelessWidget {
  const NursePatientManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Nurse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Colors.blue.shade800, // Dark blue for primary
          secondary: Colors.teal.shade400, // Teal for accents
          surface: Colors.grey.shade100, // Light grey background
        ),
        fontFamily: 'Poppins', // Modern font
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.blue.shade800,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
