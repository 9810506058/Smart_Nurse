import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/nurse_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Enhanced validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    if (value.length > 254) {
      return 'Email address is too long';
    }
    if (value.contains(RegExp(r'[^\w\s\.-@]'))) {
      return 'Email contains invalid characters';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  String? _validateName(String? value) {
    if (_isRegistering && (value == null || value.isEmpty)) {
      return 'Full name is required';
    }

    if (_isRegistering && value != null) {
      if (value.trim().split(' ').length < 2) {
        return 'Please enter both first and last name';
      }

      // ✅ Corrected regex pattern using double quotes for raw string
      RegExp nameRegex = RegExp(r"^[\w\s'\-]{2,}$");
      if (!nameRegex.hasMatch(value)) {
        return 'Invalid name format';
      }

      if (value.length > 50) {
        return 'Name is too long';
      }
    }

    return null;
  }

  bool _validateSpecializations() {
    if (_selectedSpecializations.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isRegistering && !_validateSpecializations()) {
      _showErrorMessage('Please select at least one specialization');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isRegistering) {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await NurseService().createNurse(
          userId: userCredential.user!.uid,
          name: _nameController.text.trim(),
          role: _selectedRole,
          shift: _selectedShift,
          specializations: _selectedSpecializations,
        );

        if (!mounted) return;
        _showSuccessMessage('Account created successfully!');
        _navigateToDashboard();
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;
        _navigateToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(_getErrorMessage(e.code));
    } catch (e) {
      _showErrorMessage('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'weak-password':
        return 'Password must be at least 8 characters';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network request failed. Check your connection.';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';
      default:
        return 'Login failed. Please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isRegistering ? 'Create Account' : 'Welcome Back',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_isRegistering) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateName,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.work),
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
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'day',
                              child: Text('Day Shift'),
                            ),
                            DropdownMenuItem(
                              value: 'evening',
                              child: Text('Evening Shift'),
                            ),
                            DropdownMenuItem(
                              value: 'night',
                              child: Text('Night Shift'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedShift = value!);
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Specializations (select at least one)'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _availableSpecializations.map((spec) {
                            final isSelected =
                                _selectedSpecializations.contains(spec);
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
                        if (_isRegistering && _selectedSpecializations.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Please select at least one specialization',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: _validatePassword,
                        autofillHints: const [AutofillHints.password],
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(_isRegistering ? 'Register' : 'Sign In'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isRegistering = !_isRegistering;
                                  _formKey.currentState?.reset();
                                });
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
      ),
    );
  }
}
