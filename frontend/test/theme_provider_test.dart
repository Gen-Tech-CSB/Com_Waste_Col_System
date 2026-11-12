import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_waste_frontend/providers/theme_provider.dart';

void main() {
  test('appearance is saved and restored after reopening', () async {
    String? saved;
    final first = ThemeProvider(
      read: () async => saved,
      write: (value) async {
        saved = value;
      },
    );
    await first.load();
    expect(await first.setMode(ThemeMode.light), true);
    final reopened = ThemeProvider(
      read: () async => saved,
      write: (_) async {},
    );
    await reopened.load();
    expect(reopened.mode, ThemeMode.light);
    first.dispose();
    reopened.dispose();
  });
  test('a late storage read does not replace a fresh user selection', () async {
    final read = Completer<String?>();
    final theme = ThemeProvider(read: () => read.future, write: (_) async {});
    final loading = theme.load();
    await theme.setMode(ThemeMode.light);
    read.complete('dark');
    await loading;
    expect(theme.mode, ThemeMode.light);
    theme.dispose();
  });
  test('rapid selections are persisted in order', () async {
    final writes = <String>[];
    final theme = ThemeProvider(
      read: () async => null,
      write: (value) async {
        await Future<void>.delayed(Duration.zero);
        writes.add(value);
      },
    );
    await Future.wait([
      theme.setMode(ThemeMode.light),
      theme.setMode(ThemeMode.dark),
      theme.setMode(ThemeMode.system),
    ]);
    expect(writes, ['light', 'dark', 'system']);
    expect(theme.mode, ThemeMode.system);
    theme.dispose();
  });
  test('storage failures do not prevent changing appearance', () async {
    final theme = ThemeProvider(
      read: () async => throw StateError('unavailable'),
      write: (_) async => throw StateError('unavailable'),
    );
    await theme.load();
    expect(await theme.setMode(ThemeMode.light), false);
    expect(theme.mode, ThemeMode.light);
    theme.dispose();
  });
}
