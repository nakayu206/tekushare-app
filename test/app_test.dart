import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/app.dart';

void main() {
  group('TekuShareApp', () {
    testWidgets('can be instantiated and renders', (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(child: TekuShareApp()),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
