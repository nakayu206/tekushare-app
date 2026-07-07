import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/usecases/photo/attach_photo_to_spot.dart';
import 'package:tekushare/domain/usecases/spot/get_spots.dart';
import 'package:tekushare/domain/usecases/spot/save_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot_status.dart';
import 'package:tekushare/infrastructure/camera_service.dart';
import 'package:tekushare/screens/pages/map/view/walk_route_page.dart';
import 'package:tekushare/screens/pages/settings/view/settings_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/pages/spot/view/want_to_go_page.dart';
import 'package:tekushare/screens/pages/walk/view/end_walk_page.dart';
import 'package:tekushare/screens/pages/walk/view/walk_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/location_provider.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/core/theme/app_sizing_theme.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

// ──────────────────────────────────────────
// フェイク実装
// ──────────────────────────────────────────

class _FakeSaveSpot implements SaveSpot {
  const _FakeSaveSpot();
  @override
  Future<String> call({
    required String title,
    required double latitude,
    required double longitude,
    String? memo,
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
  Future<void> call(String spotId, String imagePath) async {}
}

final _spotOverride = spotProvider.overrideWith(
  (ref) => SpotNotifier(
    saveSpot: const _FakeSaveSpot(),
    getSpots: const _FakeGetSpots(),
    updateSpotStatus: const _FakeUpdateSpotStatus(),
    attachPhotoToSpot: const _FakeAttachPhotoToSpot(),
  ),
);

class _FakeCameraService extends Fake implements CameraService {
  _FakeCameraService(this._returnPath);
  final String? _returnPath;

  @override
  Future<String?> takePhoto() async => _returnPath;
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

// ──────────────────────────────────────────
// テスト
// ──────────────────────────────────────────

void main() {
  group('WalkPage', () {
    void setDisplaySize(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<void> pumpWalkPage(
      WidgetTester tester, {
      Stream<Position>? locationStream,
      CameraService? camera,
    }) async {
      setDisplaySize(tester);

      final overrides = <Override>[
        locationProvider.overrideWith(
          (ref) => locationStream ?? const Stream.empty(),
        ),
        if (camera != null) cameraServiceProvider.overrideWith((ref) => camera),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
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
            home: const WalkPage(),
          ),
        ),
      );
      await tester.pump();
    }

    // 3つのボタンが表示される
    testWidgets('shows three buttons', (tester) async {
      await pumpWalkPage(tester);

      expect(find.text(AppStrings.takePhoto), findsOneWidget);
      expect(find.text(AppStrings.wantToGo), findsOneWidget);
      expect(find.text(AppStrings.endWalk), findsOneWidget);
    });

    // ボトムナビが表示される
    testWidgets('shows bottom navigation', (tester) async {
      await pumpWalkPage(tester);

      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    // GPS 取得中は loading インジケーターが表示される
    testWidgets('shows loading indicator while GPS is acquiring',
        (tester) async {
      await pumpWalkPage(tester, locationStream: const Stream.empty());

      expect(find.text(AppStrings.gpsAcquiring), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // GPS 取得失敗時はエラーテキストが表示される
    testWidgets('shows error text when GPS is unavailable', (tester) async {
      final errorStream = Stream<Position>.error(Exception('GPS error'));

      await pumpWalkPage(tester, locationStream: errorStream);
      await tester.pump();

      expect(find.text(AppStrings.gpsUnavailableError), findsOneWidget);
    });

    // GPS 未取得でカメラボタンをタップするとエラー SnackBar が表示される
    testWidgets('shows snackbar when camera tapped without GPS',
        (tester) async {
      await pumpWalkPage(tester, locationStream: const Stream.empty());

      await tester.tap(find.text(AppStrings.takePhoto));
      await tester.pump();

      expect(find.text(AppStrings.gpsUnavailableError), findsWidgets);
    });

    // GPS 取得済みで撮影すると pendingPhotoProvider に保存される
    testWidgets('stores photo path in pendingPhotoProvider when photo taken',
        (tester) async {
      const imagePath = '/fake/photo.jpg';
      final position = _makePosition(35.6895, 139.6917);

      await pumpWalkPage(
        tester,
        locationStream: Stream.value(position),
        camera: _FakeCameraService(imagePath),
      );
      await tester.pump();

      await tester.tap(find.text(AppStrings.takePhoto));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WalkPage)),
      );
      expect(container.read(pendingPhotoProvider), imagePath);
    });

    // GPS 取得済みで撮影すると photoTaken SnackBar が表示される
    testWidgets('shows photoTaken snackbar after photo is taken',
        (tester) async {
      const imagePath = '/fake/photo.jpg';
      final position = _makePosition(35.6895, 139.6917);

      await pumpWalkPage(
        tester,
        locationStream: Stream.value(position),
        camera: _FakeCameraService(imagePath),
      );
      await tester.pump();

      await tester.tap(find.text(AppStrings.takePhoto));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.photoTaken), findsOneWidget);
    });

    // カメラをキャンセルした場合は pendingPhotoProvider に保存しない
    testWidgets('does not store photo when camera is cancelled',
        (tester) async {
      final position = _makePosition(35.0, 139.0);

      await pumpWalkPage(
        tester,
        locationStream: Stream.value(position),
        camera: _FakeCameraService(null),
      );
      await tester.pump();

      await tester.tap(find.text(AppStrings.takePhoto));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WalkPage)),
      );
      expect(container.read(pendingPhotoProvider), isNull);
    });

    // 行きたいボタンをタップすると WantToGoPage へ遷移する
    testWidgets('navigates to WantToGoPage when want-to-go button is tapped',
        (tester) async {
      setDisplaySize(tester);

      final locationStream =
          Stream<Position>.error(Exception('GPS unavailable'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            locationProvider.overrideWith((ref) => locationStream),
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
                  MaterialPageRoute(builder: (_) => const WalkPage()),
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.wantToGo));
      await tester.pumpAndSettle();

      expect(find.byType(WantToGoPage), findsOneWidget);
    });

    // 散歩を終了するボタンをタップすると EndWalkPage へ遷移する
    testWidgets('navigates to EndWalkPage when end walk button is tapped',
        (tester) async {
      setDisplaySize(tester);

      final locationStream =
          Stream<Position>.error(Exception('GPS unavailable'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            locationProvider.overrideWith((ref) => locationStream),
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
                  MaterialPageRoute(builder: (_) => const WalkPage()),
                ),
                child: const Text('start'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();
      expect(find.byType(WalkPage), findsOneWidget);

      await tester.tap(find.text(AppStrings.endWalk));
      await tester.pumpAndSettle();
      expect(find.byType(EndWalkPage), findsOneWidget);
    });

    // ボトムナビのホームをタップすると前の画面に戻る
    testWidgets('tapping bottom nav home goes back to previous screen',
        (tester) async {
      setDisplaySize(tester);

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
                  MaterialPageRoute(builder: (_) => const WalkPage()),
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

      expect(find.byType(WalkPage), findsNothing);
    });

    // ボトムナビのリストをタップすると SpotListPage へ遷移する
    testWidgets('tapping bottom nav list navigates to SpotListPage',
        (tester) async {
      setDisplaySize(tester);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [_spotOverride],
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
                  MaterialPageRoute(builder: (_) => const WalkPage()),
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
      setDisplaySize(tester);

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
                  MaterialPageRoute(builder: (_) => const WalkPage()),
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

    // ボトムナビの設定をタップすると SettingsPage へ遷移する
    testWidgets('tapping bottom nav settings navigates to SettingsPage',
        (tester) async {
      setDisplaySize(tester);

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
                  MaterialPageRoute(builder: (_) => const WalkPage()),
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

    // GPS 取得済みのとき FlutterMap が表示される
    testWidgets('shows FlutterMap when GPS position is available',
        (tester) async {
      final position = _makePosition(35.6895, 139.6917);

      await pumpWalkPage(
        tester,
        locationStream: Stream.value(position),
      );
      await tester.pump();

      expect(find.byType(FlutterMap), findsOneWidget);
    });

    // GPS 未取得のとき FlutterMap は表示されない
    testWidgets('does not show FlutterMap when GPS is not yet available',
        (tester) async {
      await pumpWalkPage(tester, locationStream: const Stream.empty());

      expect(find.byType(FlutterMap), findsNothing);
    });

    // 撮影すると地図上に ClipOval サムネイルが追加される
    testWidgets('adds photo marker on map after taking photo', (tester) async {
      const imagePath = '/fake/photo.jpg';
      final position = _makePosition(35.6895, 139.6917);

      await pumpWalkPage(
        tester,
        locationStream: Stream.value(position),
        camera: _FakeCameraService(imagePath),
      );
      await tester.pump();

      expect(find.byType(ClipOval), findsNothing);

      await tester.tap(find.text(AppStrings.takePhoto));
      await tester.pumpAndSettle();

      expect(find.byType(ClipOval), findsOneWidget);
    });

    // 撮影をキャンセルした場合は地図上にサムネイルが追加されない
    testWidgets('does not add photo marker when camera is cancelled',
        (tester) async {
      final position = _makePosition(35.0, 139.0);

      await pumpWalkPage(
        tester,
        locationStream: Stream.value(position),
        camera: _FakeCameraService(null),
      );
      await tester.pump();

      await tester.tap(find.text(AppStrings.takePhoto));
      await tester.pumpAndSettle();

      expect(find.byType(ClipOval), findsNothing);
    });
  });
}
