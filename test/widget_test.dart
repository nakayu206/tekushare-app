import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tekushare/app.dart';
import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

void main() {
  // アプリが起動してホーム画面が表示される
  testWidgets('launches app and shows home screen', (tester) async {
    // スマートフォンサイズでテスト
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AppConfig.setFlavor(Flavor.dev);
    await tester.pumpWidget(
      const ProviderScope(child: TekuShareApp()),
    );
    await tester.pump();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
  });
}
