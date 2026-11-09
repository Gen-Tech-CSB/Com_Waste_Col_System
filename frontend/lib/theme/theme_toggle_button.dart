import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:community_waste_frontend/providers/theme_provider.dart';

/// Drop this into any AppBar's `actions` (or a corner of the login screen)
/// to let users choose System, Light or Dark.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  static IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.select<ThemeProvider, ThemeMode>((p) => p.mode);

    return PopupMenuButton<ThemeMode>(
      tooltip: 'Change theme',
      icon: Icon(_iconFor(mode)),
      initialValue: mode,
      onSelected: (m) => context.read<ThemeProvider>().setMode(m),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: ThemeMode.system,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.brightness_auto_outlined),
            title: Text('System'),
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.light_mode_outlined),
            title: Text('Light'),
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.dark_mode_outlined),
            title: Text('Dark'),
          ),
        ),
      ],
    );
  }
}
