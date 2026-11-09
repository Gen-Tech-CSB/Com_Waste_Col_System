import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_waste_frontend/main.dart' as app;
import 'package:community_waste_frontend/services/api_config.dart';

void main() {
  testWidgets('Login renders and validates empty input', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Log In'), findsOneWidget);
    await tester.ensureVisible(find.text('Log In'));
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email address.'), findsOneWidget);
    expect(find.text('Please enter your password.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('API origin supports Android emulator and desktop', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(ApiConfig.baseUrl, 'http://10.0.2.2:3000/api');
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    expect(ApiConfig.baseUrl, 'http://localhost:3000/api');
    debugDefaultTargetPlatformOverride = null;
  });
}
