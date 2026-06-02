import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/presentation/widgets/common/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('ラベルが正しく表示される', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PrimaryButton(
                label: 'テスト',
                onPressed: _noop,
              ),
            ),
          ),
        ),
      );

      expect(find.text('テスト'), findsOneWidget);
    });

    testWidgets('タップ時に onPressed が呼ばれる', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PrimaryButton(
                label: 'テスト',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });
  });
}

void _noop() {}
