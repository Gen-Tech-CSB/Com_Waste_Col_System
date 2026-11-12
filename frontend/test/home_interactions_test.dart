import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:community_waste_frontend/providers/announcement_provider.dart';
import 'package:community_waste_frontend/providers/schedule_provider.dart';
import 'package:community_waste_frontend/screens/schedule_screen.dart';
import 'package:community_waste_frontend/screens/guide_screen.dart';
import 'package:community_waste_frontend/widgets/ui.dart';
import 'package:community_waste_frontend/theme/app_theme.dart';

void main() {
  testWidgets('interactive cards support keyboard activation', (tester) async {
    var activations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: InteractiveCard(
              onTap: () => activations++,
              child: const Text('Open collection details'),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(activations, 1);
  });
  for (final width in [360.0, 1440.0]) {
    testWidgets(
      'collection filters, expandable tips and quick actions work at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var selected = '';
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ScheduleProvider()),
              ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
            ],
            child: MaterialApp(
              theme: AppTheme.dark,
              home: Scaffold(
                body: ScheduleScreen(
                  onReport: () => selected = 'report',
                  onGuide: () => selected = 'guide',
                  onProfile: () => selected = 'profile',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final report = find.widgetWithText(InteractiveCard, 'Report an issue');
        await tester.scrollUntilVisible(
          report,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(report);
        expect(selected, 'report');
        final monday = find.widgetWithText(InteractiveCard, 'Monday');
        await tester.scrollUntilVisible(
          monday,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(monday);
        await tester.pumpAndSettle();
        expect(
          find.text('Keep food scraps and leaves separate from other waste.'),
          findsOneWidget,
        );
        final filter = find.widgetWithText(ChoiceChip, 'Recyclable');
        await tester.ensureVisible(filter);
        await tester.pumpAndSettle();
        await tester.tap(filter);
        await tester.pumpAndSettle();
        expect(find.text('No collections in this category'), findsOneWidget);
        final reset = find.text('Show all collections');
        await tester.scrollUntilVisible(
          reset,
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(reset);
        await tester.pumpAndSettle();
        expect(find.widgetWithText(InteractiveCard, 'Monday'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'sorting guide searches examples and clears empty results at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: GuideScreen()),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'batteries');
        await tester.pumpAndSettle();
        expect(find.text('1 category found'), findsOneWidget);
        final special = find.widgetWithText(InteractiveCard, 'Special waste');
        await tester.scrollUntilVisible(
          special,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(special);
        await tester.pumpAndSettle();
        expect(find.text('Batteries'), findsOneWidget);
        await tester.ensureVisible(find.byType(TextField));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'xyz-no-result');
        await tester.pumpAndSettle();
        expect(find.text('No matching waste categories'), findsOneWidget);
        await tester.tap(find.byTooltip('Clear search'));
        await tester.pumpAndSettle();
        expect(find.text('4 categories to explore'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
