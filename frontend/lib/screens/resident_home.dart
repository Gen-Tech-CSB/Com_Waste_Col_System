import '../services/api_client.dart';

import 'package:flutter/material.dart';

import '../widgets/ui.dart';
import 'schedule_screen.dart';
import 'report_screen.dart';
import 'my_reports_screen.dart';
import 'guide_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class ResidentHome extends StatefulWidget {
  final ApiClient? api;
  const ResidentHome({super.key, this.api});
  @override
  State<ResidentHome> createState() => _ResidentHomeState();
}

class _ResidentHomeState extends State<ResidentHome> {
  int _selectedIndex = 0;
  late final ApiClient _api = widget.api ?? ApiClient.instance;
  static final _labels = [
    'Collection schedule',
    'Report an issue',
    'My reports',
    'Sorting guide',
    'My profile',
  ];
  static final _icons = [
    Icons.calendar_month_outlined,
    Icons.add_circle_outline,
    Icons.receipt_long_outlined,
    Icons.eco_outlined,
    Icons.person_outline,
  ];
  late final _screens = [
    const ScheduleScreen(),
    const ReportScreen(),
    const MyReportsScreen(),
    const GuideScreen(),
    ProfileScreen(
      api: _api,
      onChanged: () {
        if (mounted) setState(() {});
      },
    ),
  ];

  void _logout() {
    _api.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(api: widget.api)),
    );
  }

  void _openSettings() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SettingsScreen(
        api: _api,
        onOpenProfile: () {
          if (mounted) setState(() => _selectedIndex = 4);
        },
      ),
    ),
  );

  Widget _sidebar(BuildContext context) {
    final colors = Ui.of(context);
    return Container(
      width: 248,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
      child: Material(
        color: colors.surface,
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.recycling,
                              color: colors.green,
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Community\nWaste',
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      Padding(
                        padding: const EdgeInsets.only(left: 14, bottom: 16),
                        child: Text(
                          'RESIDENT WORKSPACE',
                          style: TextStyle(
                            color: colors.muted,
                            fontSize: 10,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                      for (var i = 0; i < _labels.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            selected: i == _selectedIndex,
                            selectedTileColor: colors.green.withValues(
                              alpha: 0.12,
                            ),
                            selectedColor: colors.green,
                            iconColor: colors.muted,
                            textColor: colors.muted,
                            leading: Icon(_icons[i], size: 21),
                            title: Text(
                              _labels[i],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () => setState(() => _selectedIndex = i),
                          ),
                        ),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Settings'),
                        textColor: colors.muted,
                        iconColor: colors.muted,
                        onTap: _openSettings,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SurfaceCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.spa_outlined, color: colors.green),
                              const SizedBox(height: 12),
                              Text(
                                'Small habits.\nCleaner communities.',
                                style: TextStyle(
                                  color: colors.text,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.logout, size: 20),
                          title: const Text('Sign out'),
                          textColor: colors.muted,
                          iconColor: colors.muted,
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      return Scaffold(
        backgroundColor: Ui.of(context).background,
        appBar: wide
            ? null
            : AppBar(
                backgroundColor: Ui.of(context).background,
                foregroundColor: Ui.of(context).text,
                centerTitle: false,
                title: const Text(
                  'Community Waste',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                leading: Icon(Icons.recycling, color: Ui.of(context).green),
                actions: [
                  IconButton(
                    tooltip: 'Open profile',
                    onPressed: () => setState(() => _selectedIndex = 4),
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: Ui.of(context).green,
                      child: Icon(
                        Icons.person_outline,
                        color: Ui.of(context).onAccent,
                        size: 19,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: _openSettings,
                    icon: const Icon(Icons.settings_outlined),
                  ),
                  IconButton(
                    tooltip: 'Sign out',
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, size: 20),
                  ),
                ],
              ),
        body: SafeArea(
          child: Row(
            children: [
              if (wide) _sidebar(context),
              Expanded(
                child: Column(
                  children: [
                    if (wide)
                      Container(
                        height: 76,
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Ui.of(context).border),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _labels[_selectedIndex],
                              style: TextStyle(
                                color: Ui.of(context).muted,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Ui.of(context).muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Your community',
                              style: TextStyle(
                                color: Ui.of(context).muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              tooltip: 'Open profile',
                              onPressed: () =>
                                  setState(() => _selectedIndex = 4),
                              icon: CircleAvatar(
                                radius: 17,
                                backgroundColor: Ui.of(context).green,
                                child: Icon(
                                  Icons.person_outline,
                                  size: 20,
                                  color: Ui.of(context).onAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: _screens,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                backgroundColor: Ui.of(context).surface,
                indicatorColor: Ui.of(context).green.withValues(alpha: 0.18),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) =>
                    setState(() => _selectedIndex = i),
                destinations: [
                  for (var i = 0; i < _labels.length; i++)
                    NavigationDestination(
                      icon: Icon(
                        _icons[i],
                        color: _selectedIndex == i
                            ? Ui.of(context).green
                            : Ui.of(context).muted,
                      ),
                      label: [
                        'Schedule',
                        'Report',
                        'My reports',
                        'Guide',
                        'Profile',
                      ][i],
                    ),
                ],
              ),
      );
    },
  );
}
