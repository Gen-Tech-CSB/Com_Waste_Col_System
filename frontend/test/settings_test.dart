import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:community_waste_frontend/providers/theme_provider.dart';
import 'package:community_waste_frontend/providers/schedule_provider.dart';
import 'package:community_waste_frontend/providers/announcement_provider.dart';
import 'package:community_waste_frontend/screens/resident_home.dart';
import 'package:community_waste_frontend/screens/settings_screen.dart';
import 'package:community_waste_frontend/services/api_client.dart';
import 'package:community_waste_frontend/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    // Font files are needed only for the Windows screenshot references.
    if (!Platform.isWindows || const bool.fromEnvironment('LAYOUT_ONLY')) {
      return;
    }
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
    for (final font in {
      'Roboto': 'roboto-regular.ttf',
      'MaterialIcons': 'MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(font.key)
        ..addFont(
          Future.value(
            ByteData.sublistView(
              await File(
                '$root/bin/cache/artifacts/material_fonts/${font.value}',
              ).readAsBytes(),
            ),
          ),
        );
      await loader.load();
    }
  });
  for (final width in [360.0, 1440.0]) {
    testWidgets('profile icon and saved appearance choices work at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? saved;
      final theme = ThemeProvider(
        read: () async => saved,
        write: (value) async {
          saved = value;
        },
      );
      final api = ApiClient(
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'success': true,
              'data': request.url.path.endsWith('/areas')
                  ? []
                  : {
                      'id': 1,
                      'full_name': 'Maria Santos',
                      'email': 'maria@example.com',
                      'phone': null,
                      'area_id': null,
                      'role': 'resident',
                    },
            }),
            200,
          ),
        ),
      )..token = 'session';
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: theme),
            ChangeNotifierProvider(create: (_) => ScheduleProvider()),
            ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
          ],
          child: Builder(
            builder: (context) => MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: context.watch<ThemeProvider>().mode,
              home: ResidentHome(api: api),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Open profile'));
      await tester.pumpAndSettle();
      expect(find.text('Your profile'), findsOneWidget);
      final settings = width < 900
          ? find.byTooltip('Settings')
          : find.widgetWithText(ListTile, 'Settings');
      await tester.ensureVisible(settings);
      await tester.tap(settings);
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      for (final choice in ['Light mode', 'Dark mode']) {
        await tester.scrollUntilVisible(
          find.text(choice),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text(choice));
        await tester.pumpAndSettle();
        final brightness = choice == 'Light mode'
            ? Brightness.light
            : Brightness.dark;
        expect(
          Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
          brightness,
        );
        expect(saved, brightness == Brightness.light ? 'light' : 'dark');
        if (Platform.isWindows && !const bool.fromEnvironment('LAYOUT_ONLY')) {
          await expectLater(
            find.byType(SettingsScreen),
            matchesGoldenFile('goldens/settings_${width.toInt()}_$saved.png'),
          );
        }
        expect(tester.takeException(), isNull);
      }
      await tester.scrollUntilVisible(
        find.text('Use device setting'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Use device setting'));
      await tester.pumpAndSettle();
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
        Brightness.light,
      );
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
        Brightness.dark,
      );
      expect(saved, 'system');
      await tester.scrollUntilVisible(
        find.text('Open my profile'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Open my profile'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.text('Your profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
