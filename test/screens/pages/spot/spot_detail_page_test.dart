import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_colors.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/usecases/photo/attach_photo_to_spot.dart';
import 'package:tekushare/domain/usecases/photo/remove_photo_from_spot.dart';
import 'package:tekushare/domain/usecases/spot/delete_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot.dart';
import 'package:tekushare/domain/usecases/spot/get_spots.dart';
import 'package:tekushare/domain/usecases/spot/save_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot_status.dart';
import 'package:tekushare/infrastructure/camera_service.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_detail_page.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/contact_provider.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

class _FakeSaveSpot implements SaveSpot {
  const _FakeSaveSpot();
  @override
  Future<String> call({
    required String title,
    required double latitude,
    required double longitude,
    String? memo,
    String? category,
    SpotStatus status = SpotStatus.wantToGo,
  }) async =>
      'fake-id';
}

class _FakeGetSpots implements GetSpots {
  const _FakeGetSpots();
  @override
  Stream<List<Spot>> call({SpotStatus? filter}) => Stream.value(const []);
}

class _FakeUpdateSpotStatus implements UpdateSpotStatus {
  const _FakeUpdateSpotStatus();
  @override
  Future<void> call(String spotId, SpotStatus status) async {}
}

class _FakeAttachPhotoToSpot implements AttachPhotoToSpot {
  const _FakeAttachPhotoToSpot();
  @override
  Future<String> call(String spotId, String imagePath) async => imagePath;
}

class _FakeRemovePhotoFromSpot implements RemovePhotoFromSpot {
  const _FakeRemovePhotoFromSpot();
  @override
  Future<void> call(String spotId, String imagePath) async {}
}

class _FakeUpdateSpot implements UpdateSpot {
  const _FakeUpdateSpot();
  @override
  Future<void> call(Spot spot) async {}
}

class _FakeDeleteSpot implements DeleteSpot {
  const _FakeDeleteSpot();
  @override
  Future<void> call(String id) async {}
}

class _FakeCameraService extends Fake implements CameraService {
  _FakeCameraService(this._path);
  final String? _path;
  @override
  Future<String?> takePhoto() async => _path;
}

Spot _makeSpot({SpotStatus status = SpotStatus.wantToGo}) => Spot(
      id: 'test-id',
      title: 'テストスポット',
      latitude: 35.0,
      longitude: 135.0,
      status: status,
      createdAt: DateTime(2024, 1, 1),
    );

final _spotOverride = spotProvider.overrideWith(
  (ref) => SpotNotifier(
    saveSpot: const _FakeSaveSpot(),
    getSpots: const _FakeGetSpots(),
    updateSpot: const _FakeUpdateSpot(),
    updateSpotStatus: const _FakeUpdateSpotStatus(),
    attachPhotoToSpot: const _FakeAttachPhotoToSpot(),
    removePhotoFromSpot: const _FakeRemovePhotoFromSpot(),
    deleteSpot: const _FakeDeleteSpot(),
  ),
);

final _cameraOverride = cameraServiceProvider.overrideWith(
  (ref) => _FakeCameraService(null),
);

void main() {
  group('SpotDetailPage', () {
    Future<void> pumpPage(
      WidgetTester tester, {
      bool isWantToGo = true,
      CameraService? camera,
    }) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
            if (camera != null)
              cameraServiceProvider.overrideWith((ref) => camera)
            else
              _cameraOverride,
          ],
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
            home: SpotDetailPage(
              spot: _makeSpot(
                status: isWantToGo ? SpotStatus.wantToGo : SpotStatus.visited,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    Future<void> pumpPushedPage(
      WidgetTester tester, {
      bool isWantToGo = true,
    }) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
            _cameraOverride,
          ],
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
                  MaterialPageRoute(
                    builder: (_) => SpotDetailPage(
                      spot: _makeSpot(
                        status: isWantToGo
                            ? SpotStatus.wantToGo
                            : SpotStatus.visited,
                      ),
                    ),
                  ),
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();
    }

    // ──────────────────────────────────────────
    // 表示
    // ──────────────────────────────────────────

    // 行きたい！モードでタイトルが「行きたい！」になる
    testWidgets('shows want-to-go title in want-to-go mode', (tester) async {
      await pumpPage(tester, isWantToGo: true);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(AppStrings.wantToGoPageTitle),
        ),
        findsOneWidget,
      );
    });

    // 行った！モードでタイトルが「行った！」になる
    testWidgets('shows went title in went mode', (tester) async {
      await pumpPage(tester, isWantToGo: false);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(AppStrings.listWentTab),
        ),
        findsOneWidget,
      );
    });

    // 6つのカテゴリチップが表示される
    testWidgets('shows six category chips', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.categoryPark), findsOneWidget);
      expect(find.text(AppStrings.categoryCafe), findsOneWidget);
      expect(find.text(AppStrings.categoryLunch), findsOneWidget);
      expect(find.text(AppStrings.categoryDinner), findsOneWidget);
      expect(find.text(AppStrings.categoryGoods), findsOneWidget);
      expect(find.text(AppStrings.categoryOther), findsOneWidget);
    });

    // 写真を追加エリアが表示される
    testWidgets('shows one add photo area', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.addPhoto), findsOneWidget);
    });

    // 削除ボタンが表示される（行った！モード）
    testWidgets('shows delete button', (tester) async {
      await pumpPage(tester, isWantToGo: false);

      expect(find.text(AppStrings.spotDetailDeleteButton), findsOneWidget);
    });

    // 上書き保存ボタンが表示される
    testWidgets('shows save button', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.spotDetailSaveButton), findsOneWidget);
    });

    // ボトムナビが表示される
    testWidgets('shows bottom navigation', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    // カテゴリチップをタップすると選択色が切り替わる
    testWidgets('tapping a category chip toggles selection color',
        (tester) async {
      await pumpPage(tester);

      // 初期は未選択（listSelected 色のチップなし）
      expect(
        find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == AppColors.listSelected),
        findsNothing,
      );

      await tester.tap(find.text(AppStrings.categoryCafe));
      await tester.pump();

      expect(
        find.ancestor(
          of: find.text(AppStrings.categoryCafe),
          matching: find.byWidgetPredicate((w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color == AppColors.listSelected),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.text(AppStrings.categoryPark),
          matching: find.byWidgetPredicate((w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color == AppColors.listSelected),
        ),
        findsNothing,
      );
    });

    // ──────────────────────────────────────────
    // ボトムナビ
    // ──────────────────────────────────────────

    // ボトムナビのリストをタップすると前の画面に戻る
    testWidgets('tapping bottom nav list goes back to previous screen',
        (tester) async {
      await pumpPushedPage(tester);

      await tester.tap(find.text(AppStrings.navList));
      await tester.pumpAndSettle();

      expect(find.byType(SpotDetailPage), findsNothing);
    });

    // ボトムナビのホームをタップすると最初の画面に戻る
    testWidgets('tapping bottom nav home goes back to first screen',
        (tester) async {
      await pumpPushedPage(tester);

      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();

      expect(find.byType(SpotDetailPage), findsNothing);
    });

    // ボトムナビのルートをタップすると WalkRoutePage へ遷移する
    testWidgets('tapping bottom nav route navigates to WalkRoutePage',
        (tester) async {
      await pumpPushedPage(tester);

      await tester.tap(find.text(AppStrings.navRoute));
      await tester.pumpAndSettle();

      expect(find.byType(WalkRoutePage), findsOneWidget);
    });

    // ボトムナビの設定をタップすると SettingsPage へ遷移する
    testWidgets('tapping bottom nav settings navigates to SettingsPage',
        (tester) async {
      await pumpPushedPage(tester);

      await tester.tap(find.text(AppStrings.navSettings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    // ──────────────────────────────────────────
    // 行った！フロー
    // ──────────────────────────────────────────

    // 行った！に保存ボタンを押すと確認ダイアログが表示される
    testWidgets('pressing move to went button shows confirmation dialog',
        (tester) async {
      await pumpPage(tester, isWantToGo: true);

      await tester.tap(find.text(AppStrings.spotDetailMoveToWentButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.spotDetailMoveToWentConfirmMessage),
          findsOneWidget);
    });

    // 行った！確認でSnackBarにメッセージが表示される
    testWidgets('confirming move to went shows snackbar', (tester) async {
      await pumpPage(tester, isWantToGo: true);

      await tester.tap(find.text(AppStrings.spotDetailMoveToWentButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(AppStrings.spotDetailMoveToWentConfirmLabel),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.spotDetailMoveToWentDone), findsOneWidget);
    });

    // 行った！確認で詳細ページから離れる
    testWidgets('confirming move to went leaves the page', (tester) async {
      await pumpPushedPage(tester, isWantToGo: true);

      await tester.tap(find.text(AppStrings.spotDetailMoveToWentButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(AppStrings.spotDetailMoveToWentConfirmLabel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SpotDetailPage), findsNothing);
    });

    // 行った！確認のキャンセルでダイアログが閉じる
    testWidgets('canceling move to went closes dialog', (tester) async {
      await pumpPage(tester, isWantToGo: true);

      await tester.tap(find.text(AppStrings.spotDetailMoveToWentButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.spotDetailMoveToWentConfirmMessage),
          findsNothing);
    });

    // ──────────────────────────────────────────
    // 写真フロー
    // ──────────────────────────────────────────

    // 写真エリアをタップしてカメラをキャンセルしても写真なし状態のまま
    testWidgets('tapping photo area with camera cancelled keeps placeholder',
        (tester) async {
      await pumpPage(tester, camera: _FakeCameraService(null));

      await tester.tap(find.text(AppStrings.addPhoto));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.addPhoto), findsOneWidget);
    });

    // ──────────────────────────────────────────
    // 削除フロー
    // ──────────────────────────────────────────

    // タイトル入力時の削除確認ダイアログに入力値が表示される
    testWidgets('delete confirmation dialog shows entered title',
        (tester) async {
      await pumpPage(tester, isWantToGo: false);

      await tester.enterText(find.byType(TextField), 'テストスポット');
      await tester.tap(find.text(AppStrings.spotDetailDeleteButton));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('テストスポット'),
        ),
        findsOneWidget,
      );
    });

    // 削除ボタンを押すと削除確認ダイアログが表示される
    testWidgets('pressing delete button shows delete confirmation dialog',
        (tester) async {
      await pumpPage(tester, isWantToGo: false);

      await tester.tap(find.text(AppStrings.spotDetailDeleteButton));
      await tester.pumpAndSettle();

      expect(
          find.text(AppStrings.spotDetailDeleteConfirmMessage), findsOneWidget);
    });

    // 削除確認のキャンセルでダイアログが閉じる
    testWidgets('canceling delete confirmation closes dialog', (tester) async {
      await pumpPage(tester, isWantToGo: false);

      await tester.tap(find.text(AppStrings.spotDetailDeleteButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      expect(
          find.text(AppStrings.spotDetailDeleteConfirmMessage), findsNothing);
    });

    // 削除確認でSnackBarにメッセージが表示される
    testWidgets('confirming delete shows snackbar', (tester) async {
      await pumpPage(tester, isWantToGo: false);

      await tester.tap(find.text(AppStrings.spotDetailDeleteButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(AppStrings.spotDetailDeleteButton),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.spotDetailDeleted), findsOneWidget);
    });

    // 削除確認で詳細ページから離れる
    testWidgets('confirming delete leaves the page', (tester) async {
      await pumpPushedPage(tester, isWantToGo: false);

      await tester.tap(find.text(AppStrings.spotDetailDeleteButton));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text(AppStrings.spotDetailDeleteButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SpotDetailPage), findsNothing);
    });

    // ──────────────────────────────────────────
    // 上書き保存フロー
    // ──────────────────────────────────────────

    // 上書き保存ボタンを押すと保存確認ダイアログが表示される
    testWidgets('pressing save button shows save confirmation dialog',
        (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();

      expect(
          find.text(AppStrings.spotDetailSaveConfirmMessage), findsOneWidget);
    });

    // タイトル未入力時の確認ダイアログに（タイトルなし）が表示される
    testWidgets(
        'save confirmation dialog shows no-title placeholder when title is empty',
        (tester) async {
      await pumpPage(tester);

      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noTitle), findsOneWidget);
    });

    // タイトル入力時の確認ダイアログに入力値が表示される
    testWidgets('save confirmation dialog shows entered title', (tester) async {
      await pumpPage(tester);

      await tester.enterText(find.byType(TextField), 'テストスポット');
      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('テストスポット'),
        ),
        findsOneWidget,
      );
    });

    // 保存確認のキャンセルでダイアログが閉じる
    testWidgets('canceling save confirmation closes dialog', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.spotDetailSaveConfirmMessage), findsNothing);
    });

    // 保存確認でSnackBarにメッセージが表示される
    testWidgets('confirming save shows snackbar', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pump();

      expect(find.text(AppStrings.saved), findsOneWidget);
    });

    // 保存確認で詳細ページから離れる
    testWidgets('confirming save leaves the page', (tester) async {
      await pumpPushedPage(tester);

      await tester.tap(find.text(AppStrings.spotDetailSaveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();

      expect(find.byType(SpotDetailPage), findsNothing);
    });
  });
}
