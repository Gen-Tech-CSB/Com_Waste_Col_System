import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00B0FF)]),
                  boxShadow: [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                ),
                child: const CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xFF1E293B),
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Juan Dela Cruz', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Resident', style: TextStyle(fontSize: 16, color: Color(0xFF00E676), fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.email, color: Color(0xFF00E676), size: 24),
                      SizedBox(width: 16),
                      Text('juan@email.com', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white12),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF00E676), size: 24),
                      SizedBox(width: 16),
                      Text('Poblacion, Zone 1', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}