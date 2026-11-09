import 'package:flutter/material.dart';

class AnnouncementProvider extends ChangeNotifier {
  String _currentAnnouncement = 'Walay koleksyon karong Biyernes (Holiday).';

  String get currentAnnouncement => _currentAnnouncement;

  void updateAnnouncement(String newAnnouncement) {
    if (newAnnouncement.trim().isNotEmpty) {
      _currentAnnouncement = newAnnouncement;
      notifyListeners(); // Pahibaloa ang Resident nga naay bag-o
    }
  }
}
