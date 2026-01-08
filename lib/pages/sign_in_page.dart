import 'dart:ui';
import 'package:flutter/material.dart';

import '../utils/theme_manager.dart';
import '../widgets/gradient_scaffold.dart';
import 'start_page.dart';

class SignInPage extends StatefulWidget {
  final ThemeManager themeManager;

  const SignInPage({super.key, required this.themeManager});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedGender;
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // ⚠️ NO REAL BACKEND YET – just simulate a delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (!_isLogin) {
      // Creating account → store in a simple session class for now
      final int? age = int.tryParse(_ageController.text.trim());
      UserSession.currentUser = UserProfile(
        name: _nameController.text.trim(),
        gender: _selectedGender ?? 'Not set',
        age: age ?? 0,
        email: _emailController.text.trim(),
      );
    } else {
      // Login mode – you could later load the profile here
      // For now we leave it empty.
    }

    setState(() {
      _isLoading = false;
    });

    // ✅ Go to StartPage after "sign in / sign up"
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StartPage(themeManager: widget.themeManager),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSignup = !_isLogin;

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Storium', style: TextStyle(fontFamily: 'Cinzel')),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isSignup ? 'Create Account' : 'Sign In',
                        style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSignup
                            ? 'Create your profile to begin your story journey.'
                            : 'Enter your email to continue your story.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ---------------- SIGN UP EXTRA FIELDS ----------------
                      if (isSignup) ...[
                        // Name
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            label: 'Name',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) {
                            if (isSignup) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Gender
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          dropdownColor: const Color(0xFF211835),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            label: 'Gender',
                            icon: Icons.wc,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Prefer not to say',
                              child: Text('Prefer not to say'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          validator: (value) {
                            if (isSignup && (value == null || value.isEmpty)) {
                              return 'Please select a gender';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Age
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            label: 'Age',
                            icon: Icons.cake_outlined,
                          ),
                          validator: (value) {
                            if (isSignup) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your age';
                              }
                              final age = int.tryParse(value.trim());
                              if (age == null || age <= 0 || age > 120) {
                                return 'Please enter a valid age';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ---------------- EMAIL ----------------
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Email',
                          icon: Icons.mail_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ---------------- PASSWORD ----------------
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: 'Password',
                          icon: Icons.lock_outline,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'At least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      if (_error != null) ...[
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],

                      const SizedBox(height: 10),

                      // ---------------- SUBMIT BUTTON ----------------
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF451B80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.3,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  isSignup ? 'Create Account' : 'Continue',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ---------------- TOGGLE LOGIN / SIGNUP ----------------
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _error = null;
                                });
                              },
                        child: Text(
                          isSignup
                              ? "Already have an account? Sign in"
                              : "Don't have an account? Create one",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        "Your info will be used to personalize your experience.\nStorium is not a diagnostic tool.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Colors.white60,
                          height: 1.4,
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

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        color: Colors.white70,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: Colors.white70, size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.35)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Colors.white, width: 1.4),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      fillColor: Colors.white.withOpacity(0.06),
      filled: true,
    );
  }
}

// ---------------- SIMPLE SESSION & PROFILE MODEL ----------------

class UserProfile {
  final String name;
  final String gender;
  final int age;
  final String email;

  UserProfile({
    required this.name,
    required this.gender,
    required this.age,
    required this.email,
  });
}

class UserSession {
  static UserProfile? currentUser;
}
