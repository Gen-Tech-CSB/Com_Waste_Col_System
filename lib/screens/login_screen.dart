import 'dart:ui';
import 'package:flutter/material.dart';
import 'resident_home.dart';
import 'admin_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120), // Deep Dark Blue Background
      body: Stack(
        children: [
          // 1. GLOWING BACKGROUND EFFECTS
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF00E676).withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF00B0FF).withOpacity(0.15), Colors.transparent],
                ),
              ),
            ),
          ),

          // 2. MAIN CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Glass Blur Effect
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03), // Highly transparent
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glowing Logo
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF00E676).withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E676).withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.recycling, size: 64, color: Color(0xFF00E676)),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Community Waste',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Collection & Reporting System',
                            style: TextStyle(fontSize: 14, color: Colors.white54),
                          ),
                          const SizedBox(height: 40),
                          
                          // Email Field
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00E676)),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.2),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Password Field
                          TextField(
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00E676)),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.2),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // Resident Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E676),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 10,
                                shadowColor: const Color(0xFF00E676).withOpacity(0.6),
                              ),
                              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResidentHome())),
                              child: const Text('Log In as Resident', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Admin Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard())),
                              child: const Text('Log In as Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Register Link
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
            ),
          ),
        ],
      ),
    );
  }
}