import 'package:flutter/material.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161C24),
      appBar: AppBar(
        title: const Text('Report Timeline'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Status Timeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          _buildTimelineItem('Report Submitted', 'Oct 20, 2026 - 8:00 AM', true, true),
          _buildTimelineItem('Under Review', 'Oct 20, 2026 - 10:00 AM', true, true),
          _buildTimelineItem('In Progress', 'Oct 21, 2026 - 9:00 AM', true, true),
          _buildTimelineItem('Resolved', 'Oct 22, 2026 - 2:00 PM', true, false, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, bool isCompleted, bool isActive, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? const Color(0xFF00E676) : const Color(0xFF222B36),
                border: Border.all(color: isCompleted ? const Color(0xFF00E676) : Colors.grey, width: 2),
              ),
              child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? const Color(0xFF00E676) : Colors.grey,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.grey)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}