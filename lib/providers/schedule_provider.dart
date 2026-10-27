import 'package:flutter/material.dart';

class Schedule {
  final String day;
  final String time;
  final String type;

  Schedule({required this.day, required this.time, required this.type});
}

class ScheduleProvider extends ChangeNotifier {
  final List<Schedule> _schedules = [
    Schedule(day: 'Monday', time: '6:00 AM', type: 'Biodegradable'),
    Schedule(day: 'Thursday', time: '6:00 AM', type: 'Non-Biodegradable'),
  ];

  List<Schedule> get schedules => _schedules;

  void addSchedule(String day, String time, String type) {
    _schedules.add(Schedule(day: day, time: time, type: type));
    notifyListeners();
  }

  void removeSchedule(int index) {
    _schedules.removeAt(index);
    notifyListeners();
  }
}