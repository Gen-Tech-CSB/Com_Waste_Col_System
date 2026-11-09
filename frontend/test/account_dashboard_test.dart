import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:community_waste_frontend/screens/register_screen.dart';
import 'package:community_waste_frontend/screens/admin_dashboard.dart';
import 'package:community_waste_frontend/services/api_client.dart';
import 'package:community_waste_frontend/theme/app_theme.dart';

void main() {
  testWidgets(
    'registration shows duplicate error and only succeeds after server confirmation',
    (tester) async {
      var attempts = 0;
      final api = ApiClient(
        client: MockClient((request) async {
          if (request.method == 'GET') {
            return http.Response('{"success":true,"data":[]}', 200);
          }
          final body = jsonDecode(request.body);
          expect(body['full_name'], 'New Resident');
          expect(body['email'], 'new@example.test');
          expect(body['password'], 'password123');
          expect(body.containsKey('role'), false);
          attempts++;
          return attempts == 1
              ? http.Response(
                  '{"success":false,"message":"Email already registered"}',
                  409,
                )
              : http.Response('{"success":true,"data":{"id":42}}', 201);
        }),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen(api: api)),
                ),
                child: const Text('Open registration'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open registration'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'New Resident');
      await tester.enterText(fields.at(1), 'not-an-email');
      await tester.enterText(fields.at(3), '1234567');
      await tester.enterText(fields.at(4), '1234567');
      await tester.pumpAndSettle();
      final submit = find.widgetWithText(FilledButton, 'Create account');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(attempts, 0);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      await tester.enterText(fields.at(1), 'NEW@example.test');
      await tester.enterText(fields.at(3), 'password123');
      await tester.enterText(fields.at(4), 'password123');
      await tester.pumpAndSettle();
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Email already registered'), findsOneWidget);
      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Account created. You can now sign in.'), findsNothing);
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.byType(RegisterScreen), findsNothing);
      expect(
        find.text('Account created. You can now sign in.'),
        findsOneWidget,
      );
    },
  );

  for (final width in [360.0, 1440.0]) {
    testWidgets('live dashboard loads, filters, and retries at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var fail = true;
      var filtered = false;
      final api = ApiClient(
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer admin-token');
          if (fail) return http.Response('{"success":false}', 503);
          if (request.url.path.endsWith('/summary')) {
            return http.Response(
              '{"success":true,"data":{"total":7,"submitted":2,"in_progress":1,"resolved":4}}',
              200,
            );
          }
          filtered |= request.url.queryParameters['status'] == 'resolved';
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 5,
                  'reference_no': 'WR-TEST-5',
                  'status': 'resolved',
                  'category': 'missed_pickup',
                  'description': 'Database report for testing',
                  'reporter_name': 'Resident Test',
                  'barangay_name': 'Barangay Uno',
                  'area_name': 'Purok 1',
                },
              ],
              'meta': {'total': 1},
            }),
            200,
          );
        }),
      )..token = 'admin-token';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AdminDashboard(api: api),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('unavailable'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('7'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('WR-TEST-5'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('WR-TEST-5'), findsOneWidget);
      final filter = find.widgetWithText(ChoiceChip, 'Resolved');
      await tester.ensureVisible(filter);
      await tester.tap(filter);
      await tester.pumpAndSettle();
      expect(filtered, true);
      expect(tester.takeException(), isNull);
    });
  }
}
