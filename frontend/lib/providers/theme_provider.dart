import 'package:flutter/material.dart';

/// Holds the selected theme mode (system / light / dark).
///
/// This version keeps the choice in memory only, so it resets when the app
/// closes. To remember it between launches, add the shared_preferences
/// package and store the value inside setMode / read it inside load.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  /// Kept so main.dart's `ThemeProvider()..load()` still works.
  Future<void> load() async {}

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }
}
