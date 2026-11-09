import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'resident_home.dart';
import 'admin_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  Future<void> _loginResident() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password'), backgroundColor: Colors.red),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('reg_email');
    final savedPass = prefs.getString('reg_password');

    if (savedEmail != null && savedPass != null) {
      if (_emailController.text.trim() == savedEmail && _passController.text == savedPass) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResidentHome()));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Email or Password!'), backgroundColor: Colors.red),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No account found. Please register first.'), backgroundColor: Colors.orange),
      );
    }
  }

  void _showAdminLogin(BuildContext context) {
    final TextEditingController adminEmail = TextEditingController();
    final TextEditingController adminPass = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161C24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: const Color(0xFF00E676).withOpacity(0.3), width: 1),
          ),
          title: Row(
            children: const [
              Icon(Icons.admin_panel_settings, color: Color(0xFF00E676)),
              SizedBox(width: 12),
              Text('Admin Access', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: adminEmail,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Admin Email',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF00E676)),
                  filled: true,
                  fillColor: const Color(0xFF0B1120),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: adminPass,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF00E676)),
                  filled: true,
                  fillColor: const Color(0xFF0B1120),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (adminEmail.text == 'admin@waste.com' && adminPass.text == 'admin123') {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid Admin Credentials!'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      // ✅ GITAGOAN ANG SCROLLBAR DINHI GAMIT ANG ScrollConfiguration
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Stack(
          children: [
            // Background Glows
            Positioned(
              top: -150, right: -100,
              child: Container(
                width: 500, height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF00E676).withOpacity(0.15), Colors.transparent],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150, left: -100,
              child: Container(
                width: 500, height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF00B0FF).withOpacity(0.15), Colors.transparent],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
            
            // Main Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161C24),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 20)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00E676).withOpacity(0.1),
                            border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3), width: 2),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF00E676).withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
                            ],
                          ),
                          child: const Icon(Icons.recycling, size: 64, color: Color(0xFF00E676)),
                        ),
                        const SizedBox(height: 32),
                        
                        const Text(
                          'Community Waste',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Collection & Reporting System',
                          style: TextStyle(fontSize: 14, color: Colors.white54, letterSpacing: 1),
                        ),
                        const SizedBox(height: 48),

                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00E676)),
                            filled: true,
                            fillColor: const Color(0xFF0B1120),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        TextField(
                          controller: _passController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00E676)),
                            filled: true,
                            fillColor: const Color(0xFF0B1120),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 48),

                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            onPressed: _loginResident,
                            child: const Text('Log In as Resident', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => _showAdminLogin(context),
                            child: const Text('Log In as Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                          child: const Text('Create an account', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}