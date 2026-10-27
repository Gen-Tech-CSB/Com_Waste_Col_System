import 'package:flutter/material.dart';

class ManageSchedules extends StatefulWidget {
  const ManageSchedules({super.key});

  @override
  State<ManageSchedules> createState() => _ManageSchedulesState();
}

class _ManageSchedulesState extends State<ManageSchedules> {
  final List<Map<String, String>> _schedules = [
    {'day': 'Monday', 'time': '6:00 AM', 'type': 'Biodegradable'},
    {'day': 'Thursday', 'time': '6:00 AM', 'type': 'Non-Biodegradable'},
  ];

  void _addSchedule() {
    showDialog(
      context: context,
      builder: (context) {
        String newDay = 'Monday';
        String newType = 'Biodegradable';
        final timeController = TextEditingController();

        return AlertDialog(
          title: const Text('Add New Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: newDay,
                items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
                    .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                    .toList(),
                onChanged: (val) => newDay = val!,
                decoration: const InputDecoration(labelText: 'Day'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time (e.g. 7:00 AM)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: newType,
                items: ['Biodegradable', 'Non-Biodegradable', 'Recyclable', 'Special']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => newType = val!,
                decoration: const InputDecoration(labelText: 'Waste Type'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _schedules.add({
                    'day': newDay,
                    'time': timeController.text.isEmpty ? '6:00 AM' : timeController.text,
                    'type': newType,
                  });
                });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Schedules')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.green),
              title: Text('${schedule['day']} - ${schedule['time']}'),
              subtitle: Text(schedule['type']!),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _schedules.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSchedule,
        icon: const Icon(Icons.add),
        label: const Text('Add Schedule'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}