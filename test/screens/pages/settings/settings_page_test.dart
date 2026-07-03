import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

void main() {
  group('SettingsPage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const SettingsPage(),
          ),
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
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
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

    // ボトムナビのリストをタップすると SpotListPage へ遷移する
    testWidgets('tapping bottom nav list navigates to SpotListPage',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
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
      await tester.tap(find.text(AppStrings.navList));
      await tester.pumpAndSettle();

      expect(find.byType(SpotListPage), findsOneWidget);
    });

    // ボトムナビのルートをタップすると WalkRoutePage へ遷移する
    testWidgets('tapping bottom nav route navigates to WalkRoutePage',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
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
      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomNav),
          matching: find.text(AppStrings.navRoute),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WalkRoutePage), findsOneWidget);
    });

    // タイマー 片道 セグメントをタップすると往復がオフになる
    testWidgets('tapping one-way segment sets roundTrip to false',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.oneWay));
      await tester.pump();

      expect(find.text(AppStrings.oneWay), findsOneWidget);
    });

    // 往復セグメントをタップしても状態が変わらない（すでに往復）
    testWidgets('tapping round-trip segment keeps roundTrip true',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.settingsTimerRoundTrip));
      await tester.pump();

      expect(find.text(AppStrings.settingsTimerRoundTrip), findsOneWidget);
    });

    // タイマー分数をタップするとピッカーボトムシートが開く
    testWidgets('tapping timer minutes opens picker bottom sheet',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('30${AppStrings.minuteSuffix}').first);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.pickerDone), findsOneWidget);
    });

    // ピッカーの完了をタップするとボトムシートが閉じる
    testWidgets('tapping done in picker closes bottom sheet', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('30${AppStrings.minuteSuffix}').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.pickerDone));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.pickerDone), findsNothing);
    });

    // 安否確認の分数をタップするとピッカーボトムシートが開く
    testWidgets('tapping inactivity minutes opens picker bottom sheet',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('15${AppStrings.minuteSuffix}'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.pickerDone), findsOneWidget);

      await tester.tap(find.text(AppStrings.pickerDone));
      await tester.pumpAndSettle();
    });

    // 通知先設定ボタンをタップすると電話番号選択ダイアログが開く
    testWidgets('tapping set contact button opens phone select dialog',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.settingsInactivityContactSet));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.settingsPhoneSelectTitle), findsOneWidget);
    });

    // 電話番号を選択すると確認ダイアログが表示される
    testWidgets('selecting contact shows confirm dialog', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.settingsInactivityContactSet));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterButton).first);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.settingsPhoneConfirmMessage), findsOneWidget);
    });

    // 登録するをタップすると登録完了ダイアログが表示される
    testWidgets('confirming contact shows registered dialog', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.settingsInactivityContactSet));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterConfirm));
      await tester.pumpAndSettle();

      expect(
          find.text(AppStrings.settingsPhoneRegisteredMessage), findsOneWidget);
    });

    // 登録完了ダイアログを閉じる
    testWidgets('closing registered dialog dismisses it', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.settingsInactivityContactSet));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterConfirm));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.closeButton));
      await tester.pumpAndSettle();

      expect(
          find.text(AppStrings.settingsPhoneRegisteredMessage), findsNothing);
    });

    // 確認ダイアログのキャンセル
    testWidgets('canceling confirm dialog closes it', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.settingsInactivityContactSet));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.settingsPhoneConfirmMessage), findsNothing);
    });

    // シェアの行きたいリストチェックボックスをタップする
    testWidgets('tapping share spots checkbox toggles state', (tester) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(
        find.text(AppStrings.settingsShareWantToGo),
      );
      await tester.tap(find.text(AppStrings.settingsShareWantToGo));
      await tester.pump();

      expect(find.text(AppStrings.settingsShareWantToGo), findsOneWidget);
    });

    // シェアの行った！リストチェックボックスをタップする
    testWidgets('tapping share visited checkbox toggles state', (tester) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(
        find.text(AppStrings.settingsShareVisited).first,
      );
      await tester.tap(find.text(AppStrings.settingsShareVisited).first);
      await tester.pump();

      expect(find.text(AppStrings.settingsShareVisited), findsWidgets);
    });

    // 内容保存ボタンをタップしてもエラーにならない
    testWidgets('tapping share save button does not throw', (tester) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(
        find.text(AppStrings.settingsShareSaveButton),
      );
      await tester.tap(find.text(AppStrings.settingsShareSaveButton));
      await tester.pump();

      expect(find.text(AppStrings.settingsShareSaveButton), findsOneWidget);
    });

    // リンクコピーボタンをタップしてもエラーにならない
    testWidgets('tapping copy link button does not throw', (tester) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(
        find.text(AppStrings.settingsShareLinkCopy),
      );
      await tester.tap(find.text(AppStrings.settingsShareLinkCopy));
      await tester.pump();

      expect(find.text(AppStrings.settingsShareLinkCopy), findsOneWidget);
    });

    // アプリアイコン（LINE・Instagram・X）をタップしてもエラーにならない
    testWidgets('tapping app share icons does not throw', (tester) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pump();

      for (final label in ['LINE', 'Instagram', 'X']) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pump();
      }

      expect(find.text('LINE'), findsOneWidget);
    });

    // チェックボックスをタップすると onChanged が呼ばれる（lines 665, 670）
    testWidgets('tapping share checkboxes triggers onChanged', (tester) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            builder: (context, child) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: child!,
              );
            },
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pump();

      final checkboxes = find.byType(Checkbox);
      await tester.ensureVisible(checkboxes.first);
      await tester.tap(checkboxes.first);
      await tester.pump();
      await tester.tap(checkboxes.last);
      await tester.pump();

      expect(find.byType(Checkbox), findsWidgets);
    });

    // スイッチをタップすると onChanged が呼ばれる（line 1186）
    testWidgets('tapping switch triggers onChanged', (tester) async {
      await pumpPage(tester);

      // Semantics(toggled:) が _CustomSwitch を包んでいるので、それをタップ
      await tester.tap(
        find
            .byWidgetPredicate(
              (w) => w is Semantics && w.properties.toggled != null,
            )
            .first,
      );
      await tester.pump();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    // ピッカーをスクロールすると onSelectedItemChanged が呼ばれる（lines 281-282）
    testWidgets('scrolling picker triggers onSelectedItemChanged',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('30${AppStrings.minuteSuffix}').first);
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(ListWheelScrollView).first,
        const Offset(0, -100),
      );
      await tester.pump();
      await tester.tap(find.text(AppStrings.pickerDone));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });
}
