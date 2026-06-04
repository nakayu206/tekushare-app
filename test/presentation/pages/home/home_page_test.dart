import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/presentation/pages/home/home_page.dart';
import 'package:tekushare/presentation/pages/spot/spot_list_page.dart';
import 'package:tekushare/presentation/pages/walk/walk_page.dart';

void main() {
  group('HomePage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: HomePage()),
        ),
      );
      // アニメーション（2800ms）を完了させてボタンを操作可能にする
      await tester.pump(const Duration(seconds: 3));
    }

    testWidgets('散歩をはじめるボタンをタップすると WalkPage へ遷移する', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.startWalk));
      await tester.pumpAndSettle();

      expect(find.byType(WalkPage), findsOneWidget);
    });

    testWidgets('ボトムナビのリストをタップすると SpotListPage へ遷移する', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.navList));
      await tester.pumpAndSettle();

      expect(find.byType(SpotListPage), findsOneWidget);
    });
  });
}
