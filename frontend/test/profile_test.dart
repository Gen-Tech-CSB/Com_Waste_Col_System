import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:community_waste_frontend/screens/profile_screen.dart';
import 'package:community_waste_frontend/services/api_client.dart';
import 'package:community_waste_frontend/theme/app_theme.dart';

void main() {
  for (final width in [360.0, 1440.0]) {
    testWidgets(
      'profile keeps edits after failure and saves authenticated details at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var saves = 0;
        final original = {
          'id': 9,
          'full_name': 'Original Resident',
          'email': 'resident@example.com',
          'role': 'resident',
          'phone': '123',
          'area_id': 1,
        };
        final api = ApiClient(
          client: MockClient((request) async {
            if (request.url.path.endsWith('/areas')) {
              return http.Response('{"success":false}', 503);
            }
            expect(request.headers['Authorization'], 'Bearer profile-token');
            if (request.method == 'PATCH') {
              final body = jsonDecode(request.body);
              expect(body, {
                'full_name': 'Updated Resident',
                'phone': '09001234567',
                'area_id': 1,
              });
              saves++;
              if (saves == 1) return http.Response('{"success":false}', 503);
              return http.Response(
                jsonEncode({
                  'success': true,
                  'data': {...original, ...body},
                }),
                200,
              );
            }
            return http.Response(
              jsonEncode({'success': true, 'data': original}),
              200,
            );
          }),
        )..token = 'profile-token';
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(body: ProfileScreen(api: api)),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('resident@example.com'), findsOneWidget);
        expect(
          find.textContaining('Your saved area will be kept'),
          findsOneWidget,
        );
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Updated Resident',
        );
        await tester.enterText(find.byType(TextFormField).at(1), '09001234567');
        await tester.pumpAndSettle();
        final save = find.text('Save changes');
        await tester.scrollUntilVisible(
          save,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(find.textContaining('unavailable'), findsOneWidget);
        expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField).first)
              .controller!
              .text,
          'Updated Resident',
        );
        expect(api.user!['full_name'], 'Original Resident');
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(saves, 2);
        expect(api.user!['full_name'], 'Updated Resident');
        expect(find.text('Your profile has been updated.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('profile provides sign-in recovery for an expired session', (
    tester,
  ) async {
    final api = ApiClient(
      client: MockClient((_) async => http.Response('{"success":false}', 401)),
    )..token = 'expired';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: ProfileScreen(api: api)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsOneWidget,
    );
    expect(find.text('Sign in again'), findsOneWidget);
    expect(api.token, isNull);
  });
}
