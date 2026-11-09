import 'package:flutter/material.dart';

import '../widgets/ui.dart';
import 'schedule_screen.dart';
import 'report_screen.dart';
import 'my_reports_screen.dart';
import 'guide_screen.dart';
import 'login_screen.dart';

class ResidentHome extends StatefulWidget {
  const ResidentHome({super.key});
  @override
  State<ResidentHome> createState() => _ResidentHomeState();
}

class _ResidentHomeState extends State<ResidentHome> {
  int _selectedIndex = 0;
  static const _labels = [
    'Collection schedule',
    'Report an issue',
    'My reports',
    'Sorting guide',
  ];
  static const _icons = [
    Icons.calendar_month_outlined,
    Icons.add_circle_outline,
    Icons.receipt_long_outlined,
    Icons.eco_outlined,
  ];
  static const _screens = [
    ScheduleScreen(),
    ReportScreen(),
    MyReportsScreen(),
    GuideScreen(),
  ];

  void _logout() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      return Scaffold(
        backgroundColor: Ui.background,
        appBar: wide
            ? null
            : AppBar(
                backgroundColor: Ui.background,
                foregroundColor: Colors.white,
                centerTitle: false,
                title: const Text(
                  'Community Waste',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                leading: const Icon(Icons.recycling, color: Ui.green),
                actions: [
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
              if (wide)
                Container(
                  width: 248,
                  decoration: const BoxDecoration(
                    color: Ui.surface,
                    border: Border(right: BorderSide(color: Ui.border)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 32,
                  ),
                  child: Material(
                    color: Ui.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(Icons.recycling, color: Ui.green, size: 32),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'Community\nWaste',
                                  style: TextStyle(
                                    color: Colors.white,
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
                        const Padding(
                          padding: EdgeInsets.only(left: 14, bottom: 16),
                          child: Text(
                            'RESIDENT WORKSPACE',
                            style: TextStyle(
                              color: Ui.muted,
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
                              selectedTileColor: Ui.green.withValues(
                                alpha: 0.12,
                              ),
                              selectedColor: Ui.green,
                              iconColor: Ui.muted,
                              textColor: Ui.muted,
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
                        const Spacer(),
                        const SurfaceCard(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.spa_outlined, color: Ui.green),
                              SizedBox(height: 12),
                              Text(
                                'Small habits.\nCleaner communities.',
                                style: TextStyle(
                                  color: Colors.white,
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
                          textColor: Ui.muted,
                          iconColor: Ui.muted,
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    if (wide)
                      Container(
                        height: 76,
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Ui.border)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _labels[_selectedIndex],
                              style: const TextStyle(
                                color: Ui.muted,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Ui.muted,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Your community',
                              style: TextStyle(color: Ui.muted, fontSize: 12),
                            ),
                            const SizedBox(width: 20),
                            const CircleAvatar(
                              radius: 17,
                              backgroundColor: Ui.green,
                              child: Icon(
                                Icons.person_outline,
                                size: 20,
                                color: Ui.background,
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
                backgroundColor: Ui.surface,
                indicatorColor: Ui.green.withValues(alpha: 0.18),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) =>
                    setState(() => _selectedIndex = i),
                destinations: [
                  for (var i = 0; i < _labels.length; i++)
                    NavigationDestination(
                      icon: Icon(
                        _icons[i],
                        color: _selectedIndex == i ? Ui.green : Ui.muted,
                      ),
                      label: const [
                        'Schedule',
                        'Report',
                        'My reports',
                        'Guide',
                      ][i],
                    ),
                ],
              ),
      );
    },
  );
}
