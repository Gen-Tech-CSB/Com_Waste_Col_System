import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/announcement_provider.dart'; // ✅ Import
import 'screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ScheduleProvider()),
        ChangeNotifierProvider(create: (context) => AnnouncementProvider()), // ✅ Register
      ],
      child: const WasteApp(),
    ),
  );
}

class WasteApp extends StatelessWidget {
  const WasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Waste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF161C24),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          surface: Color(0xFF222B36),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161C24),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}