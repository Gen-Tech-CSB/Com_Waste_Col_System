import 'package:flutter/material.dart';
import 'schedule_screen.dart';
import 'report_screen.dart';
import 'my_reports_screen.dart';
import 'guide_screen.dart';

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
        automaticallyImplyLeading: false, // ✅ KINI ANG MOTANGGAL SA BACK ARROW (PANA)
        title: const Text('Community Waste'),
        backgroundColor: const Color(0xFF161C24),
        elevation: 0,
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF222B36),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
            BoxShadow(color: const Color(0xFF00E676).withOpacity(0.1), blurRadius: 20, spreadRadius: 2),
          ],
          border: Border.all(color: const Color(0xFF2C3A47), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.calendar_month, 'Schedule'),
            _buildNavItem(1, Icons.add_a_photo, 'Report'),
            _buildNavItem(2, Icons.list_alt, 'My Reports'),
            _buildNavItem(3, Icons.menu_book, 'Guide'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E676).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00E676) : Colors.grey,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}