import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekushare/domain/entities/app_update.dart';
import 'package:tekushare/screens/providers/app_update_provider.dart';
import 'package:tekushare/screens/widgets/common/app_update_gate.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('設定取得が失敗してもアプリを利用できる', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appUpdateLoaderProvider
            .overrideWithValue(() async => throw Exception('offline')),
      ],
      child: const MaterialApp(
          home: AppUpdateGate(child: Scaffold(body: Text('home')))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(find.text('アップデートする'), findsNothing);
  });

  Widget app({required int minimum}) => ProviderScope(
        overrides: [
          installedBuildLoaderProvider.overrideWithValue(() async => 13),
          appUpdateLoaderProvider.overrideWithValue(() async => AppUpdate(
                latestBuild: 15,
                minimumBuild: minimum,
                version: '1.0.2',
                storeUri: Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.tekushare.app'),
              )),
        ],
        child: const MaterialApp(
            home: AppUpdateGate(child: Scaffold(body: Text('home')))),
      );

  testWidgets('通常更新はあとで閉じ、同じビルドの案内を再表示しない', (tester) async {
    await tester.pumpWidget(app(minimum: 13));
    await tester.pumpAndSettle();
    expect(find.text('新しいてくしぇあが届きました'), findsOneWidget);
    await tester.tap(find.text('あとで'));
    await tester.pumpAndSettle();
    expect(find.text('新しいてくしぇあが届きました'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(minimum: 13));
    await tester.pumpAndSettle();
    expect(find.text('新しいてくしぇあが届きました'), findsNothing);
  });

  testWidgets('必須更新は後回しにできず、通常更新の既読設定でも表示する', (tester) async {
    await tester.pumpWidget(app(minimum: 13));
    await tester.pumpAndSettle();
    await tester.tap(find.text('あとで'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(minimum: 14));
    await tester.pumpAndSettle();
    expect(find.text('アップデートをお願いします'), findsOneWidget);
    expect(find.text('あとで'), findsNothing);
  });
}
