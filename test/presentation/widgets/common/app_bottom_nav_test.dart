import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/presentation/widgets/common/app_bottom_nav.dart';

void main() {
  group('AppBottomNav', () {
    testWidgets('選択インデックスが正しく設定される', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(currentIndex: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 2);
    });

    testWidgets('タップ時に onTap が呼ばれる', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('リスト'));
      expect(tappedIndex, 1);
    });
  });
}
