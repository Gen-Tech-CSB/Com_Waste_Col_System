import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/api_client.dart';
import '../widgets/ui.dart';

class SettingsScreen extends StatelessWidget {
  final ApiClient? api;
  final VoidCallback? onOpenProfile;
  const SettingsScreen({super.key, this.api, this.onOpenProfile});

  Future<void> _choose(BuildContext context, ThemeMode mode) async {
    final saved = await context.read<ThemeProvider>().setMode(mode);
    if (!saved && context.mounted) {
      showNotice(
        context,
        'Appearance changed, but this device could not remember it.',
      );
    }
  }

  Widget _choice(
    BuildContext context,
    ThemeMode value,
    IconData icon,
    String label,
    String description,
    bool selected,
  ) {
    final colors = Ui.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? colors.green.withValues(alpha: 0.10)
            : colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? colors.green : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _choose(context, value),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: selected ? colors.green : colors.muted,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(
                          color: colors.muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? colors.green : colors.muted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeProvider>().mode;
    final colors = Ui.of(context);
    final user = (api ?? ApiClient.instance).user;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colors.background,
        foregroundColor: colors.text,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 600 ? 20 : 36,
            ),
            children: [
              const PageHeading(
                eyebrow: 'Make it yours',
                title: 'Your space. Your style.',
                subtitle: 'Choose the appearance that feels right for you.',
              ),
              const SizedBox(height: 28),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette_outlined, color: colors.green),
                        const SizedBox(width: 12),
                        Text(
                          'Appearance',
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your choice is remembered on this device.',
                      style: TextStyle(color: colors.muted, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    _choice(
                      context,
                      ThemeMode.light,
                      Icons.light_mode_outlined,
                      'Light mode',
                      'A bright, fresh workspace.',
                      mode == ThemeMode.light,
                    ),
                    const SizedBox(height: 12),
                    _choice(
                      context,
                      ThemeMode.dark,
                      Icons.dark_mode_outlined,
                      'Dark mode',
                      'A softer look for darker spaces.',
                      mode == ThemeMode.dark,
                    ),
                    const SizedBox(height: 12),
                    _choice(
                      context,
                      ThemeMode.system,
                      Icons.brightness_auto_outlined,
                      'Use device setting',
                      'Follow your device’s light or dark appearance.',
                      mode == ThemeMode.system,
                    ),
                  ],
                ),
              ),
              if (onOpenProfile != null) ...[
                const SizedBox(height: 20),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your account',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?['email']?.toString() ??
                            'View your personal details and collection area.',
                        style: TextStyle(color: colors.muted, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onOpenProfile!();
                        },
                        icon: const Icon(Icons.person_outline),
                        label: const Text('Open my profile'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.recycling, size: 20, color: colors.green),
                  const SizedBox(width: 10),
                  Text(
                    'Community Waste',
                    style: TextStyle(color: colors.muted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
