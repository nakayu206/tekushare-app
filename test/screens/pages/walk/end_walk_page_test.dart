import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/screens/pages/walk/view/end_walk_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

void main() {
  group('EndWalkPage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: EndWalkPage()),
        ),
      );
      await tester.pump();
    }

    // 確認メッセージが表示される
    testWidgets('shows end walk confirm message', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.endWalkConfirmMessage), findsOneWidget);
    });

    // キャンセルボタンが表示される
    testWidgets('shows cancel button', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.cancelButton), findsOneWidget);
    });

    // 終了するボタンが表示される
    testWidgets('shows confirm button', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.endWalkConfirmButton), findsOneWidget);
    });

    // ボトムナビが表示される
    testWidgets('shows bottom navigation', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    // キャンセルボタンで前の画面に戻る
    testWidgets('tapping cancel goes back to previous screen', (tester) async {
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
                  MaterialPageRoute(builder: (_) => const EndWalkPage()),
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();
      expect(find.byType(EndWalkPage), findsOneWidget);

      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();
      expect(find.byType(EndWalkPage), findsNothing);
    });

    // 終了するボタンでホーム画面へ戻る
    testWidgets('tapping confirm goes back to home screen', (tester) async {
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
                  MaterialPageRoute(builder: (_) => const EndWalkPage()),
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();
      expect(find.byType(EndWalkPage), findsOneWidget);

      await tester.tap(find.text(AppStrings.endWalkConfirmButton));
      await tester.pumpAndSettle();
      expect(find.byType(EndWalkPage), findsNothing);
    });
  });
}
