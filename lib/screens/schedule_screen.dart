import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kini ang nagbasa sa data gikan sa Admin
    final schedules = context.watch<ScheduleProvider>().schedules;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Your Collection Schedule',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Kini ang nag-drowing sa matag schedule
        ...schedules.map((schedule) {
          bool isBio = schedule.type == 'Biodegradable';
          Color color = isBio 
              ? Colors.green 
              : (schedule.type == 'Recyclable' ? Colors.orange : Colors.blue);
          IconData icon = isBio 
              ? Icons.eco 
              : (schedule.type == 'Recyclable' ? Icons.recycling : Icons.delete);

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: color, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(schedule.day, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(schedule.time, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(schedule.type, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}