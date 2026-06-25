import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

void main() {
  group('SettingsPage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SettingsPage()),
        ),
      );
      await tester.pump();
    }

    // タイトルが表示される（AppBar + BottomNav で複数出る）
    testWidgets('shows page title', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.settingsTitle), findsAtLeastNWidgets(1));
    });

    // タイマーセクションが表示される
    testWidgets('shows timer section', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.settingsTimerTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsTimerSubtitle), findsOneWidget);
    });

    // 安否確認セクションが表示される
    testWidgets('shows inactivity section', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.settingsInactivityTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsInactivitySubtitle), findsOneWidget);
    });

    // シェアセクションが表示される
    testWidgets('shows share section', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.settingsShareTitle), findsOneWidget);
      expect(find.text(AppStrings.settingsShareSubtitle), findsOneWidget);
    });

    // ボトムナビが表示される
    testWidgets('shows bottom navigation', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    // タイマーの初期値が ON で表示される
    testWidgets('timer switch shows ON by default', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.switchOn), findsWidgets);
    });

    // 安否確認の初期値が OFF で表示される
    testWidgets('inactivity switch shows OFF by default', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.switchOff), findsOneWidget);
    });

    // ボトムナビのリストタップで前の画面に戻る
    testWidgets('tapping bottom nav list goes to previous screen',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsNothing);
    });
  });
}
