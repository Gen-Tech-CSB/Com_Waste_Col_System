import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Full Name'),
            const SizedBox(height: 8),
            const TextField(decoration: InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const Text('Email'),
            const SizedBox(height: 8),
            const TextField(decoration: InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const Text('Password'),
            const SizedBox(height: 8),
            const TextField(obscureText: true, decoration: InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}