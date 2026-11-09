import 'dart:async';

import '../widgets/ui.dart';

import 'package:flutter/material.dart';

import 'resident_home.dart';
import 'admin_dashboard.dart';
import 'register_screen.dart';

// ---------------------------------------------------------------------------
// AUTH LAYER (mock)
// Replace the body of AuthService.login with a real call to your API:
//   POST http://localhost:3000/api/auth/login  { email, password }
// The server should return a JWT and the user's role (resident / admin).
// ---------------------------------------------------------------------------
enum UserRole { resident, admin }

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class AuthService {
  static Future<UserRole> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network

    // TEMPORARY mock accounts - remove once the backend is connected.
    if (email.toLowerCase() == 'admin@waste.com' && password == 'admin123') {
      return UserRole.admin;
    }
    if (email.toLowerCase() == 'resident@waste.com' &&
        password == 'resident123') {
      return UserRole.resident;
    }
    throw const AuthException('Incorrect email or password.');
  }
}

// ---------------------------------------------------------------------------
// LOGIN SCREEN
// ---------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final role = await AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => role == UserRole.admin
              ? const AdminDashboard()
              : const ResidentHome(),
        ),
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to sign in. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Ui.background,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 950;
          return Row(
            children: [
              if (wide)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Ui.green,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.recycling,
                                size: 32,
                                color: Ui.background,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Community Waste',
                                style: TextStyle(
                                  color: Ui.background,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                          const Icon(
                            Icons.spa_outlined,
                            size: 88,
                            color: Color(0xFF3B602D),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'A little care.\nA cleaner\ncommunity.',
                            style: TextStyle(
                              color: Ui.background,
                              fontSize: 48,
                              height: 1.1,
                              letterSpacing: -2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Stay on top of collections, report issues, and build better waste habits together.',
                            style: TextStyle(
                              color: Color(0xFF36512D),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 48),
                          const Text(
                            'SORT SMART. LIVE CLEAN.',
                            style: TextStyle(
                              color: Ui.background,
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!wide) ...[
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.recycling,
                                    size: 42,
                                    color: Ui.green,
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                              const PageHeading(
                                eyebrow: 'Community Waste',
                                title: 'Welcome back.',
                                subtitle: 'Sign in to take care of your corner of the world.',
                              ),
                              const SizedBox(height: 32),
                              if (_error != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF422A28),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Color(0xFFFFB4AB),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                              TextFormField(
                                controller: _emailCtrl,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.username],
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email address',
                                  hintText: 'you@example.com',
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email address.';
                                  }
                                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                      .hasMatch(value.trim())) {
                                    return 'Enter a valid email address.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passCtrl,
                                style: const TextStyle(color: Colors.white),
                                obscureText: _obscure,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _obscure
                                        ? 'Show password'
                                        : 'Hide password',
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Please enter your password.'
                                    : value.length < 6
                                    ? 'Password must be at least 6 characters.'
                                    : null,
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                height: 54,
                                child: FilledButton(
                                  onPressed: _loading ? null : _submit,
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Log In',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    "New to the community?",
                                    style: TextStyle(color: Ui.muted),
                                  ),
                                  TextButton(
                                    onPressed: _loading
                                        ? null
                                        : () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          ),
                                    child: const Text('Create an account'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
