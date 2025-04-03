import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/nurse_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegistering = false;
  String _selectedRole = 'nurse';
  String _selectedShift = 'day';
  final List<String> _selectedSpecializations = [];

  final List<String> _availableSpecializations = [
    'General Care',
    'Critical Care',
    'Emergency',
    'Pediatrics',
    'Surgery',
    'Mental Health',
  ];

  Future<void> _handleSubmit() async {
    try {
      if (_isRegistering) {
        // Create user account
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Create nurse profile
        final nurseService = NurseService();
        await nurseService.createNurse(
          userId: userCredential.user!.uid,
          name: _nameController.text.trim(),
          role: _selectedRole,
          shift: _selectedShift,
          specializations: _selectedSpecializations,
        );
      } else {
        // Sign in existing user
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isRegistering ? 'Create Account' : 'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (_isRegistering) ...[
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'nurse',
                            child: Text('Nurse'),
                          ),
                          DropdownMenuItem(
                            value: 'supervisor',
                            child: Text('Supervisor'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRole = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedShift,
                        decoration: const InputDecoration(
                          labelText: 'Shift',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'day',
                            child: Text('Day'),
                          ),
                          DropdownMenuItem(
                            value: 'evening',
                            child: Text('Evening'),
                          ),
                          DropdownMenuItem(
                            value: 'night',
                            child: Text('Night'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedShift = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Specializations'),
                      Wrap(
                        spacing: 8,
                        children: _availableSpecializations.map((spec) {
                          final isSelected = _selectedSpecializations.contains(spec);
                          return FilterChip(
                            label: Text(spec),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSpecializations.add(spec);
                                } else {
                                  _selectedSpecializations.remove(spec);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _handleSubmit,
                      child: Text(_isRegistering ? 'Register' : 'Sign In'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() => _isRegistering = !_isRegistering);
                      },
                      child: Text(
                        _isRegistering
                            ? 'Already have an account? Sign in'
                            : 'Need an account? Register',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
