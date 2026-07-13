import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/pages/spot/view/want_to_go_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/providers/contact_provider.dart';
import 'package:tekushare/screens/providers/location_provider.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

class _FakeCameraService extends CameraService {
  _FakeCameraService(this._returnPath) : super();
  final String? _returnPath;
  @override
  Future<String?> takePhoto() async => _returnPath;
  @override
  Future<String?> pickFromGallery() async => _returnPath;
}

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
      'fake-spot-id';
}

class _FakeGetSpots implements GetSpots {
  const _FakeGetSpots();
  @override
  Stream<List<Spot>> call({SpotStatus? filter}) => const Stream.empty();
}

class _FakeUpdateSpotStatus implements UpdateSpotStatus {
  const _FakeUpdateSpotStatus();
  @override
  Future<void> call(String spotId, SpotStatus status) async {}
}

class _FakeAttachPhotoToSpot implements AttachPhotoToSpot {
  const _FakeAttachPhotoToSpot();
  @override
  Future<void> call(String spotId, String imagePath) async {}
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

Position _makePosition(double lat, double lng) => Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

final _locationOverride = locationProvider.overrideWith(
  (ref) => Stream.value(_makePosition(35.0, 135.0)),
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

void main() {
  group('WantToGoPage', () {
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _locationOverride,
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
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
            home: Consumer(
              builder: (_, ref, child) {
                ref.watch(locationProvider); // autoDisposeを防いでStreamを定着させる
                return child!;
              },
              child: const WantToGoPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // ページタイトルが表示される
    testWidgets('shows page title', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.wantToGoPageTitle), findsOneWidget);
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

    // 写真を追加ボタンが表示される
    testWidgets('shows add photo button', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.addPhoto), findsOneWidget);
    });

    // 保存ボタンが表示される
    testWidgets('shows save button', (tester) async {
      await pumpPage(tester);

      expect(find.text(AppStrings.wantToGoSave), findsOneWidget);
    });

    // ボトムナビが表示される
    testWidgets('shows bottom navigation', (tester) async {
      await pumpPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    // カテゴリチップをタップすると選択状態が変わる
    testWidgets('tapping a category chip changes selection state',
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

      // カフェが選択色になる
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
    });

    // GPS未取得時に保存ボタンを押すとスナックバーが表示される
    testWidgets('pressing save button without GPS shows snackbar',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
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
            home: const WantToGoPage(),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pump();

      expect(find.text(AppStrings.gpsUnavailableError), findsOneWidget);
    });

    // 保存ボタンを押すと確認ダイアログが表示される
    testWidgets('pressing save button shows confirmation dialog',
        (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.wantToGoConfirmMessage), findsOneWidget);
    });

    // タイトル未入力時の確認ダイアログに（タイトルなし）が表示される
    testWidgets(
        'confirmation dialog shows no-title placeholder when title is empty',
        (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noTitle), findsOneWidget);
    });

    // タイトル入力時の確認ダイアログに入力値が表示される
    testWidgets('confirmation dialog shows entered title', (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'テストスポット');
      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('テストスポット'),
        ),
        findsOneWidget,
      );
    });

    // 確認ダイアログのキャンセルでダイアログが閉じる
    testWidgets('canceling confirmation dialog closes dialog', (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.cancelButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.wantToGoConfirmMessage), findsNothing);
    });

    // 確認ダイアログの保存でスポットが保存されて完了ダイアログが表示される
    testWidgets('confirming save stores spot and shows save complete dialog',
        (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.saved), findsOneWidget);
    });

    // 保存完了ダイアログの閉じるでページを離れる
    testWidgets('closing save complete dialog leaves the page', (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _locationOverride,
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
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
                    builder: (_) => Consumer(
                      builder: (_, ref, child) {
                        ref.watch(locationProvider);
                        return child!;
                      },
                      child: const WantToGoPage(),
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

      await tester.tap(find.text(AppStrings.wantToGoSave));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.saveButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.closeButton));
      await tester.pumpAndSettle();

      expect(find.byType(WantToGoPage), findsNothing);
    });

    // ボトムナビのホームをタップすると前の画面に戻る
    testWidgets('tapping bottom nav home goes back to previous screen',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _locationOverride,
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
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
                  MaterialPageRoute(builder: (_) => const WantToGoPage()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.navHome));
      await tester.pumpAndSettle();

      expect(find.byType(WantToGoPage), findsNothing);
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
          overrides: [
            _locationOverride,
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
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
                  MaterialPageRoute(builder: (_) => const WantToGoPage()),
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
          overrides: [
            _locationOverride,
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
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
                  MaterialPageRoute(builder: (_) => const WantToGoPage()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.navRoute));
      await tester.pumpAndSettle();

      expect(find.byType(WalkRoutePage), findsOneWidget);
    });

    // 写真プレースホルダーをタップするとカメラが起動し写真行が表示される
    testWidgets(
        'tapping photo placeholder calls camera and shows photo row layout',
        (tester) async {
      const fakePath = '/fake/photo.jpg';
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _locationOverride,
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
            cameraServiceProvider
                .overrideWithValue(_FakeCameraService(fakePath)),
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
            home: Consumer(
              builder: (_, ref, child) {
                ref.watch(locationProvider);
                return child!;
              },
              child: const WantToGoPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 初期状態はマップのClipRRectのみ（写真なし）
      expect(find.byType(ClipRRect), findsOneWidget);

      await tester.tap(find.text(AppStrings.addPhoto));
      await tester.pumpAndSettle();

      // カメラ後は写真カードのClipRRectが追加される（マップ+写真）
      expect(find.byType(ClipRRect), findsNWidgets(2));
    });

    // ボトムナビの設定をタップすると SettingsPage へ遷移する
    testWidgets('tapping bottom nav settings navigates to SettingsPage',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            _locationOverride,
            _spotOverride,
            contactProvider.overrideWith((ref) => Stream.value([])),
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
                  MaterialPageRoute(builder: (_) => const WantToGoPage()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.navSettings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });
}
