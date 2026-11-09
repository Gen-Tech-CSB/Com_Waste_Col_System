import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:community_waste_frontend/providers/announcement_provider.dart';
import 'package:community_waste_frontend/providers/schedule_provider.dart';
import 'package:community_waste_frontend/screens/resident_home.dart';
import 'package:community_waste_frontend/screens/admin_dashboard.dart';
import 'package:community_waste_frontend/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    final config = jsonDecode(
      File('.dart_tool/package_config.json').readAsStringSync(),
    );
    final flutter = (config['packages'] as List).firstWhere(
      (p) => p['name'] == 'flutter',
    );
    final root = Directory.fromUri(Uri.parse(flutter['rootUri']))
        .parent
        .parent
        .path;
    {
      for (final entry in {
        'Roboto': 'roboto-regular.ttf',
        'MaterialIcons': 'MaterialIcons-Regular.otf',
      }.entries) {
        final file = File(
          '$root/bin/cache/artifacts/material_fonts/${entry.value}',
        );
        if (file.existsSync()) {
          final loader = FontLoader(entry.key)
            ..addFont(
              Future.value(ByteData.sublistView(await file.readAsBytes())),
            );
          await loader.load();
        }
      }
    }
  });
  for (final width in [360.0, 1440.0]) {
    testWidgets('Resident navigation fits $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ScheduleProvider()),
            ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
          ],
          child: MaterialApp(theme: AppTheme.dark, home: const ResidentHome()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(ResidentHome),
        matchesGoldenFile('goldens/resident_${width.toInt()}.png'),
      );
      final labels = width >= 900
          ? ['Report an issue', 'My reports', 'Sorting guide']
          : ['Report', 'My reports', 'Guide'];
      for (final label in labels) {
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: label);
      }
    });
    testWidgets('Admin overview scrolls at $width', (tester) async {
      tester.view.physicalSize = Size(width, 650);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const AdminDashboard()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
