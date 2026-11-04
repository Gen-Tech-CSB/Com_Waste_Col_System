import 'package:flutter/material.dart';
import 'manage_schedules.dart';
import 'login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161C24),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month, color: Color(0xFF00E676)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageSchedules()))),
          IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('System Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total', '12', const Color(0xFF1976D2), Icons.folder)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Pending', '5', const Color(0xFFFFA000), Icons.hourglass_empty)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('In Progress', '3', const Color(0xFF8E24AA), Icons.autorenew)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Resolved', '4', const Color(0xFF00E676), Icons.check_circle)),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Recent Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildReportTile('Missed Pickup', 'Poblacion - Zone 1', 'Pending', const Color(0xFFFFA000)),
                  _buildReportTile('Illegal Dumping', 'Poblacion - Zone 2', 'In Progress', const Color(0xFF8E24AA)),
                  _buildReportTile('Overflowing Bin', 'San Isidro', 'Resolved', const Color(0xFF00E676)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF222B36), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2C3A47))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildReportTile(String title, String location, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF222B36), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2C3A47))),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.report, color: statusColor, size: 24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
        subtitle: Text(location, style: const TextStyle(fontSize: 13)),
        trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold))),
      ),
    );
  }
}