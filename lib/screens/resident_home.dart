import 'package:flutter/material.dart';
import 'schedule_screen.dart';
import 'report_screen.dart';
import 'my_reports_screen.dart';
import 'guide_screen.dart';
import 'login_screen.dart';

class ResidentHome extends StatefulWidget {
  const ResidentHome({super.key});

  @override
  State<ResidentHome> createState() => _ResidentHomeState();
}

class _ResidentHomeState extends State<ResidentHome> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ScheduleScreen(),
    ReportScreen(),
    MyReportsScreen(),
    GuideScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161C24),
      appBar: AppBar(
        title: const Text('Community Waste'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF222B36),
        indicatorColor: const Color(0xFF00E676).withOpacity(0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined, color: Colors.grey), selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF00E676)), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.add_a_photo_outlined, color: Colors.grey), selectedIcon: Icon(Icons.add_a_photo, color: Color(0xFF00E676)), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined, color: Colors.grey), selectedIcon: Icon(Icons.list_alt, color: Color(0xFF00E676)), label: 'My Reports'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined, color: Colors.grey), selectedIcon: Icon(Icons.menu_book, color: Color(0xFF00E676)), label: 'Guide'),
        ],
      ),
    );
  }
}