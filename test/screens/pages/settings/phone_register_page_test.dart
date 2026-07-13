import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/domain/entities/contact.dart';
import 'package:tekushare/screens/pages/settings/view/phone_register_page.dart';
import 'package:tekushare/screens/providers/contact_provider.dart';

class _FakeContactNotifier extends ContactNotifier {
  Contact? savedContact;
  String? deletedId;

  @override
  Future<void> save(Contact contact) async => savedContact = contact;

  @override
  Future<void> delete(String id) async => deletedId = id;
}

void main() {
  group('PhoneRegisterPage', () {
    late _FakeContactNotifier fakeNotifier;

    setUp(() => fakeNotifier = _FakeContactNotifier());

    ProviderScope buildScope({Contact? existing, required Widget child}) {
      return ProviderScope(
        overrides: [
          contactNotifierProvider.overrideWith(() => fakeNotifier),
        ],
        child: MaterialApp(
          builder: (context, c) {
            final sw = MediaQuery.sizeOf(context).width;
            return Theme(
              data: Theme.of(context).copyWith(
                extensions: [AppSizingTheme.fromScreenWidth(sw)],
              ),
              child: c!,
            );
          },
          home: child,
        ),
      );
    }

    Future<void> pumpNew(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        buildScope(child: const PhoneRegisterPage()),
      );
      await tester.pump();
    }

    Future<void> pumpEdit(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        buildScope(
          child: const PhoneRegisterPage(
            existing: Contact(id: 'id1', name: 'テスト太郎', phone: '09012345678'),
          ),
        ),
      );
      await tester.pump();
    }

    // 新規モードでアプリバータイトルが表示される
    testWidgets('shows app bar title', (tester) async {
      await pumpNew(tester);
      expect(
        find.text(AppStrings.settingsInactivityContact),
        findsAtLeastNWidgets(1),
      );
    });

    // 編集モードで既存データがフォームに埋まっている
    testWidgets('prefills fields when existing contact given', (tester) async {
      await pumpEdit(tester);
      expect(find.text('テスト太郎'), findsOneWidget);
      expect(find.text('09012345678'), findsOneWidget);
    });

    // バリデーション：名前が空なら確認ダイアログが出ない
    testWidgets('does not show confirm dialog when name is empty',
        (tester) async {
      await pumpNew(tester);
      await tester.enterText(
        find.byType(TextFormField).last,
        '09012345678',
      );
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterConfirm));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.settingsPhoneConfirmMessage), findsNothing);
    });

    // 登録ボタン → 確認ダイアログが表示される
    testWidgets('tapping register shows confirm dialog', (tester) async {
      await pumpNew(tester);
      await tester.enterText(find.byType(TextFormField).first, 'テスト太郎');
      await tester.enterText(find.byType(TextFormField).last, '09012345678');
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterConfirm));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.settingsPhoneConfirmMessage), findsOneWidget);
    });

    // 確認ダイアログでキャンセルすると閉じる
    testWidgets('canceling confirm dialog dismisses it', (tester) async {
      await pumpNew(tester);
      await tester.enterText(find.byType(TextFormField).first, 'テスト太郎');
      await tester.enterText(find.byType(TextFormField).last, '09012345678');
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterConfirm));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.settingsPhoneConfirmMessage), findsNothing);
      expect(find.byType(PhoneRegisterPage), findsOneWidget);
    });

    // 確認ダイアログで登録する → 保存が呼ばれ、完了ダイアログが表示される
    testWidgets('confirming calls save and shows success dialog',
        (tester) async {
      await pumpNew(tester);
      await tester.enterText(find.byType(TextFormField).first, 'テスト太郎');
      await tester.enterText(find.byType(TextFormField).last, '09012345678');
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterConfirm));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(AppStrings.settingsPhoneRegisterConfirm).last,
      );
      await tester.pumpAndSettle();
      expect(fakeNotifier.savedContact?.name, 'テスト太郎');
      expect(
        find.text(AppStrings.settingsPhoneRegisteredMessage),
        findsOneWidget,
      );
    });

    // 完了ダイアログを閉じると消える
    testWidgets('closing success dialog dismisses it', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contactNotifierProvider.overrideWith(() => fakeNotifier),
          ],
          child: MaterialApp(
            navigatorKey: navigator,
            builder: (context, c) {
              final sw = MediaQuery.sizeOf(context).width;
              return Theme(
                data: Theme.of(context).copyWith(
                  extensions: [AppSizingTheme.fromScreenWidth(sw)],
                ),
                child: c!,
              );
            },
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const PhoneRegisterPage(),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'テスト太郎');
      await tester.enterText(find.byType(TextFormField).last, '09012345678');
      await tester.tap(find.text(AppStrings.settingsPhoneRegisterConfirm));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(AppStrings.settingsPhoneRegisterConfirm).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.closeButton));
      await tester.pumpAndSettle();
      expect(
          find.text(AppStrings.settingsPhoneRegisteredMessage), findsNothing);
      expect(find.byType(PhoneRegisterPage), findsNothing);
    });

    // 編集モードで削除ボタンが表示される
    testWidgets('shows delete button in edit mode', (tester) async {
      await pumpEdit(tester);
      expect(find.text(AppStrings.settingsPhoneDeleteButton), findsOneWidget);
    });

    // 削除ボタン → 削除確認ダイアログが表示される
    testWidgets('tapping delete shows confirm dialog', (tester) async {
      await pumpEdit(tester);
      await tester.tap(find.text(AppStrings.settingsPhoneDeleteButton));
      await tester.pumpAndSettle();
      expect(
        find.text(AppStrings.settingsPhoneDeleteConfirmMessage),
        findsOneWidget,
      );
    });

    // 削除確認ダイアログでキャンセルすると閉じる
    testWidgets('canceling delete dialog closes it', (tester) async {
      await pumpEdit(tester);
      await tester.tap(find.text(AppStrings.settingsPhoneDeleteButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();
      expect(
        find.text(AppStrings.settingsPhoneDeleteConfirmMessage),
        findsNothing,
      );
      expect(find.byType(PhoneRegisterPage), findsOneWidget);
    });

    // 削除確認ダイアログで削除すると delete が呼ばれる
    testWidgets('confirming delete calls delete', (tester) async {
      await pumpEdit(tester);
      await tester.tap(find.text(AppStrings.settingsPhoneDeleteButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.settingsPhoneDeleteConfirmButton));
      await tester.pumpAndSettle();
      expect(fakeNotifier.deletedId, 'id1');
    });
  });
}
