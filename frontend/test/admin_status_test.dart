import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:community_waste_frontend/screens/admin_dashboard.dart';
import 'package:community_waste_frontend/services/api_client.dart';
import 'package:community_waste_frontend/theme/app_theme.dart';

void main() {
  testWidgets(
    'admin status updates handle a server conflict before confirming success',
    (tester) async {
      var saves = 0;
      final report = {
        'id': 5,
        'reference_no': 'WR-5',
        'status': 'under_review',
        'category': 'missed_pickup',
        'description': 'Collection was missed.',
        'reporter_name': 'Resident',
        'barangay_name': 'Uno',
        'area_name': 'Purok 1',
      };
      final api =
          ApiClient(
              client: MockClient((request) async {
                Object data;
                if (request.method == 'PATCH') {
                  expect(jsonDecode(request.body)['status'], 'resolved');
                  saves++;
                  if (saves == 1) {
                    return http.Response(
                      '{"success":false,"message":"Report changed. Please refresh."}',
                      409,
                    );
                  }
                  report['status'] = 'resolved';
                  data = report;
                } else if (request.url.path.endsWith('/summary')) {
                  data = {
                    'total': 1,
                    'submitted': 0,
                    'in_progress': 0,
                    'resolved': saves > 1 ? 1 : 0,
                  };
                } else if (request.url.path.endsWith('/5')) {
                  data = report;
                } else {
                  return http.Response(
                    jsonEncode({
                      'success': true,
                      'data': [report],
                      'meta': {'total': 1},
                    }),
                    200,
                  );
                }
                return http.Response(
                  jsonEncode({'success': true, 'data': data}),
                  200,
                );
              }),
            )
            ..token = 'admin-token'
            ..user = {'role': 'admin'};
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: AdminDashboard(api: api),
        ),
      );
      await tester.pumpAndSettle();
      final review = find.text('Review report');
      await tester.scrollUntilVisible(
        review,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(review);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resolved').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save status'));
      await tester.pumpAndSettle();
      expect(find.text('Report changed. Please refresh.'), findsOneWidget);
      expect(find.text('Report status updated.'), findsNothing);
      await tester.tap(find.text('Save status'));
      await tester.pumpAndSettle();
      expect(saves, 2);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Report status updated.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
