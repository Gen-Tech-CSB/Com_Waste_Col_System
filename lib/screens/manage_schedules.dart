import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class ManageSchedules extends StatelessWidget {
  const ManageSchedules({super.key});

  void _showAddDialog(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    String newDay = 'Monday';
    String newType = 'Biodegradable';
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF222B36),
          title: const Text('Add New Schedule', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF161C24),
                style: const TextStyle(color: Colors.white),
                value: newDay,
                items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'].map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                onChanged: (val) => newDay = val!,
                decoration: const InputDecoration(labelText: 'Day', labelStyle: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 12),
              TextField(controller: timeController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Time (e.g. 7:00 AM)', labelStyle: TextStyle(color: Colors.grey))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF161C24),
                style: const TextStyle(color: Colors.white),
                value: newType,
                items: ['Biodegradable', 'Non-Biodegradable', 'Recyclable', 'Special'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => newType = val!,
                decoration: const InputDecoration(labelText: 'Waste Type', labelStyle: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
              onPressed: () {
                provider.addSchedule(newDay, timeController.text.isEmpty ? '6:00 AM' : timeController.text, newType);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedules = context.watch<ScheduleProvider>().schedules;

    return Scaffold(
      backgroundColor: const Color(0xFF161C24),
      appBar: AppBar(title: const Text('Manage Schedules')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: const Color(0xFF222B36), borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Color(0xFF00E676)),
              title: Text('${schedule.day} - ${schedule.time}', style: const TextStyle(color: Colors.white)),
              subtitle: Text(schedule.type, style: const TextStyle(color: Colors.grey)),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => context.read<ScheduleProvider>().removeSchedule(index)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Schedule'),
        backgroundColor: const Color(0xFF00E676),
        foregroundColor: Colors.black,
      ),
    );
  }
}