import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schedules = context.watch<ScheduleProvider>().schedules;

    return Scaffold(
      backgroundColor: const Color(0xFF161C24),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Collection Schedule', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Row(children: [Icon(Icons.location_on_outlined, color: Colors.grey, size: 16), SizedBox(width: 4), Text('Purok 1, Barangay Uno', style: TextStyle(fontSize: 14, color: Colors.grey))]),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF222B36), border: Border.all(color: const Color(0xFF2C3A47))),
                    child: const Icon(Icons.person, color: Color(0xFF00E676)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2D1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3), width: 1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Monday, 6:00 AM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
                          SizedBox(height: 4),
                          Text('Put all waste out by 6:00 AM', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ]),
                        Text('In 2 days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...schedules.map((schedule) {
                    bool isBio = schedule.type == 'Biodegradable';
                    Color color = isBio ? const Color(0xFF00E676) : (schedule.type == 'Recyclable' ? const Color(0xFFFFA000) : const Color(0xFF00B0FF));
                    return _buildDayCard(schedule.day, schedule.time, color);
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(String day, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF222B36), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2C3A47))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(Icons.calendar_today_outlined, color: color, size: 20), const SizedBox(width: 8), Text(day, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))]),
              Text(time, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTag('Biodegradable', const Color(0xFF00E676)),
              _buildTag('Non-Bio', const Color(0xFFFFA000)),
              _buildTag('Recyclable', const Color(0xFF00B0FF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 8, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold))]),
    );
  }
}