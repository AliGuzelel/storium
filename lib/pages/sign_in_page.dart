import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_session.dart';
import '../providers/saved_images_store.dart';
import '../providers/settings_manager.dart';
import '../services/auth_service.dart';
import '../services/story_progress_service.dart';
import '../services/user_session_cloud_sync.dart';
import '../theme/ui_tokens.dart';
import '../utils/app_strings.dart';
import '../utils/theme_manager.dart';
import '../widgets/app_button.dart';
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

  final _nameController = TextEditingController();
  DateTime? _dateOfBirth;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedGender;
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;
  final AuthService _authService = AuthService();
  final StoryProgressService _storyProgressService = StoryProgressService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final settingsManager = Provider.of<SettingsManager>(
      context,
      listen: false,
    );
    final savedImagesStore = Provider.of<SavedImagesStore>(
      context,
      listen: false,
    );

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (!_isLogin) {
        if (_dateOfBirth == null) {
          setState(() {
            _isLoading = false;
            _error = 'Please select your date of birth';
          });
          return;
        }

        final profile = await _authService.signUp(
          name: _nameController.text.trim(),
          gender: _selectedGender ?? 'Not set',
          email: email,
          dateOfBirth: _dateOfBirth,
          password: password,
        );
        UserSession.currentUser = profile;
      } else {
        final profile = await _authService.signIn(
          email: email,
          password: password,
        );
        UserSession.currentUser = profile;
      }

      await UserSession.saveCurrentUser();
      await UserSessionCloudSync.hydrateIfSignedIn(
        settingsManager: settingsManager,
      );
      await savedImagesStore.load();
      await _storyProgressService.seedAnnouncedWithCurrentlyUnlocked();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StartPage(themeManager: widget.themeManager),
        ),
      );
    } on AuthServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSignup = !_isLogin;

    return GradientScaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: UiTokens.pagePadding),
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
                        isSignup
                            ? t(context, 'create_account')
                            : t(context, 'sign_in'),
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
                      const SizedBox(height: UiTokens.sectionGap),

                      if (isSignup) ...[
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            label: t(context, 'name'),
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
                        const SizedBox(height: UiTokens.itemGap),

                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          dropdownColor: const Color(0xFF211835),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            label: t(context, 'gender'),
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
                        const SizedBox(height: UiTokens.itemGap),

                        _datePickerPill(
                          label: t(context, 'date_of_birth'),
                          icon: Icons.calendar_month_rounded,
                          value: _dateOfBirth,
                          onPick: _pickDateOfBirth,
                        ),
                        const SizedBox(height: UiTokens.itemGap),
                      ],

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: t(context, 'email'),
                          icon: Icons.mail_outline,
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!v.contains('@') || !v.contains('.com')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: UiTokens.itemGap),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          label: t(context, 'password'),
                          icon: Icons.lock_outline,
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (v.length < 6) {
                            return 'At least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: UiTokens.itemGap),

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

                      const SizedBox(height: UiTokens.itemGap),

                      _isLoading
                          ? const SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.3,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : AppButton(
                              label: isSignup
                                  ? t(context, 'create_account')
                                  : t(context, 'continue'),
                              onTap: _submit,
                            ),

                      const SizedBox(height: 10),

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

  Widget _datePickerPill({
    required String label,
    required IconData icon,
    required DateTime? value,
    required VoidCallback onPick,
  }) {
    final text = value == null
        ? 'Pick a date'
        : '${value.day}/${value.month}/${value.year}';

    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF211835),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    DateTime tempDate = _dateOfBirth ?? DateTime(2000);
    final didSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Select Date of Birth',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
          ),
          content: SizedBox(
            width: 320,
            child: CalendarDatePicker(
              initialDate: tempDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onDateChanged: (picked) {
                tempDate = picked;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save Date'),
            ),
          ],
        );
      },
    );

    if (didSave == true && mounted) {
      setState(() {
        _dateOfBirth = tempDate;
        if (_error == 'Please select your date of birth') {
          _error = null;
        }
      });
    }
  }
}
