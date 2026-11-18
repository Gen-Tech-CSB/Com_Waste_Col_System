import 'package:flutter/material.dart';
import 'report_detail_screen.dart'; // ✅ Import sa Timeline

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  // Mock list. Kung gusto nimo testingan ang Empty State, i-comment out ang sud.
  final List<Map<String, String>> _reports = [
    {'title': 'Missed Pickup', 'date': 'Oct 20, 2026', 'status': 'Resolved'},
  ];

  @override
  Widget build(BuildContext context) {
    return _reports.isEmpty
        ? const Center(
            // 🚨 EMPTY STATE DESIGN
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Wala pa kay na-submit nga report.', style: TextStyle(fontSize: 16, color: Colors.white70)),
                SizedBox(height: 8),
                Text('Click "Report" to submit a new one.', style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('My Reports', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              ..._reports.map((report) {
                return GestureDetector(
                  onTap: () {
                    // ✅ MO-ADTO SA TIMELINE
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportDetailScreen()));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222B36),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2C3A47)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(report['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF00E676).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(report['status']!, style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(report['date']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
  }
}