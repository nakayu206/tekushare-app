import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/widgets/common/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    Widget wrap(Widget child) => MaterialApp(
          builder: (context, app) {
            final sw = MediaQuery.sizeOf(context).width;
            return Theme(
              data: Theme.of(context).copyWith(
                extensions: [AppSizingTheme.fromScreenWidth(sw)],
              ),
              child: Scaffold(body: Center(child: child)),
            );
          },
        );

    // ラベルが正しく表示される
    testWidgets('shows label correctly', (tester) async {
      await tester.pumpWidget(
        wrap(const PrimaryButton(label: 'テスト', onPressed: _noop)),
      );

      expect(find.text('テスト'), findsOneWidget);
    });

    // タップ時に onPressed が呼ばれる
    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrap(PrimaryButton(label: 'テスト', onPressed: () => tapped = true)),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });
  });
}

void _noop() {}
