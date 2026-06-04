import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/presentation/pages/spot/want_to_go_page.dart';
import 'package:tekushare/presentation/pages/walk/walk_page.dart';
import 'package:tekushare/presentation/widgets/common/app_bottom_nav.dart';

void main() {
  group('WalkPage', () {
    setUp(() {});

    Future<void> pumpWalkPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: WalkPage()),
        ),
      );
      await tester.pump();
    }

    testWidgets('3つのボタンが表示される', (tester) async {
      await pumpWalkPage(tester);

      expect(find.text(AppStrings.takePhoto), findsOneWidget);
      expect(find.text(AppStrings.saveToWantToGo), findsOneWidget);
      expect(find.text(AppStrings.endWalk), findsOneWidget);
    });

    testWidgets('ボトムナビが表示される', (tester) async {
      await pumpWalkPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    testWidgets('撮影するボタンをタップしても何も起きない', (tester) async {
      await pumpWalkPage(tester);

      await tester.tap(find.text(AppStrings.takePhoto));
      await tester.pump();

      expect(find.byType(WalkPage), findsOneWidget);
    });

    testWidgets('行きたいリストに保存ボタンをタップすると WantToGoPage へ遷移する',
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
                  MaterialPageRoute(builder: (_) => const WalkPage()),
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.saveToWantToGo));
      await tester.pumpAndSettle();

      expect(find.byType(WantToGoPage), findsOneWidget);
    });

    testWidgets('散歩を終了するで前の画面に戻る', (tester) async {
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
                  MaterialPageRoute(builder: (_) => const WalkPage()),
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();
      expect(find.byType(WalkPage), findsOneWidget);

      await tester.tap(find.text(AppStrings.endWalk));
      await tester.pumpAndSettle();
      expect(find.byType(WalkPage), findsNothing);
    });
  });
}
