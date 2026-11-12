import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'package:community_waste_frontend/providers/announcement_provider.dart';
import 'package:community_waste_frontend/providers/schedule_provider.dart';
import 'package:community_waste_frontend/providers/theme_provider.dart';
import 'package:community_waste_frontend/screens/login_screen.dart';
import 'package:community_waste_frontend/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
      ],
      child: const WasteApp(),
    ),
  );
}

class WasteApp extends StatelessWidget {
  const WasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild only when the theme mode changes.
    final themeMode = context.select<ThemeProvider, ThemeMode>((p) => p.mode);

    return MaterialApp(
      title: 'Community Waste',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const LoginScreen(),
    );
  }
}
