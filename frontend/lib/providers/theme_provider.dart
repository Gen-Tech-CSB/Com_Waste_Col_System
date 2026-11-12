import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  final Future<String?> Function() _read;
  final Future<void> Function(String) _write;
  Future<void> _pendingWrite = Future.value();
  int _revision = 0;
  bool _disposed = false;

  ThemeProvider({
    Future<String?> Function()? read,
    Future<void> Function(String)? write,
  }) : _read =
           read ??
           (() => SharedPreferencesAsync().getString('appearance_mode')),
       _write =
           write ??
           ((value) =>
               SharedPreferencesAsync().setString('appearance_mode', value));

  Future<void> load() async {
    final revision = _revision;
    try {
      final value = await _read();
      if (_disposed || revision != _revision) return;
      final saved = ThemeMode.values
          .where((mode) => mode.name == value)
          .firstOrNull;
      if (saved != null && saved != _mode) {
        _mode = saved;
        notifyListeners();
      }
    } catch (_) {
      /* Appearance is still usable if device storage is unavailable. */
    }
  }

  Future<bool> setMode(ThemeMode mode) async {
    if (_disposed) return false;
    _revision++;
    if (mode != _mode) {
      _mode = mode;
      notifyListeners();
    }
    _pendingWrite = _pendingWrite
        .catchError((_) {})
        .then((_) => _write(mode.name));
    try {
      await _pendingWrite;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
