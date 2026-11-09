import 'package:flutter/material.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161C24),
      appBar: AppBar(
        title: const Text('Activity Log'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildLogItem('Added new schedule for Wednesday', 'Oct 25, 2026 - 9:00 AM', Icons.add_circle, const Color(0xFF00E676)),
          _buildLogItem('Marked report #123 as Resolved', 'Oct 24, 2026 - 3:30 PM', Icons.check_circle, const Color(0xFF00E676)),
          _buildLogItem('Posted announcement: No collection on Friday', 'Oct 23, 2026 - 10:00 AM', Icons.campaign, const Color(0xFFFFA000)),
          _buildLogItem('Deleted schedule for Tuesday', 'Oct 22, 2026 - 1:00 PM', Icons.delete, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildLogItem(String action, String date, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222B36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C3A47)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}