import '../widgets/ui.dart';

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
          backgroundColor: Ui.of(context).surface,
          title: Text(
            'Add New Schedule',
            style: TextStyle(color: Ui.of(context).text),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: Ui.of(context).background,
                style: TextStyle(color: Ui.of(context).text),
                initialValue: newDay,
                items:
                    [
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday',
                          'Saturday',
                        ]
                        .map(
                          (day) =>
                              DropdownMenuItem(value: day, child: Text(day)),
                        )
                        .toList(),
                onChanged: (val) => newDay = val!,
                decoration: InputDecoration(
                  labelText: 'Day',
                  labelStyle: TextStyle(color: Ui.of(context).muted),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                style: TextStyle(color: Ui.of(context).text),
                decoration: InputDecoration(
                  labelText: 'Time (e.g. 7:00 AM)',
                  labelStyle: TextStyle(color: Ui.of(context).muted),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: Ui.of(context).background,
                style: TextStyle(color: Ui.of(context).text),
                initialValue: newType,
                items:
                    [
                          'Biodegradable',
                          'Non-Biodegradable',
                          'Recyclable',
                          'Special',
                        ]
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (val) => newType = val!,
                decoration: InputDecoration(
                  labelText: 'Waste Type',
                  labelStyle: TextStyle(color: Ui.of(context).muted),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Ui.of(context).muted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Ui.of(context).green,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                provider.addSchedule(
                  newDay,
                  timeController.text.isEmpty ? '6:00 AM' : timeController.text,
                  newType,
                );
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
      backgroundColor: Ui.of(context).background,
      appBar: AppBar(title: const Text('Manage Schedules')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Ui.of(context).surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Ui.of(context).green),
              title: Text(
                '${schedule.day} - ${schedule.time}',
                style: TextStyle(color: Ui.of(context).text),
              ),
              subtitle: Text(
                schedule.type,
                style: TextStyle(color: Ui.of(context).muted),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Ui.of(context).danger),
                onPressed: () =>
                    context.read<ScheduleProvider>().removeSchedule(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Schedule'),
        backgroundColor: Ui.of(context).green,
        foregroundColor: Colors.black,
      ),
    );
  }
}
