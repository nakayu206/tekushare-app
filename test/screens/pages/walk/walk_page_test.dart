import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/infrastructure/camera_service.dart';
import 'package:tekushare/screens/pages/spot/view/want_to_go_page.dart';
import 'package:tekushare/screens/pages/walk/view/end_walk_page.dart';
import 'package:tekushare/screens/pages/walk/view/walk_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/location_provider.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

// ──────────────────────────────────────────
// フェイク実装
// ──────────────────────────────────────────

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
          child: const MaterialApp(home: WalkPage()),
        ),
      );
      await tester.pump();
    }

    // 3つのボタンが表示される
    testWidgets('shows three buttons', (tester) async {
      await pumpWalkPage(tester);

      expect(find.text(AppStrings.takePhoto), findsOneWidget);
      expect(find.text(AppStrings.saveToWantToGo), findsOneWidget);
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
      await tester.pump(); // stream 受信

      await tester.tap(find.text(AppStrings.takePhoto));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WalkPage)),
      );
      expect(container.read(pendingPhotoProvider), imagePath);
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

    // 行きたいリストに保存ボタンをタップすると WantToGoPage へ遷移する
    testWidgets(
        'navigates to WantToGoPage when save to want-to-go button is tapped',
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

      await tester.tap(find.text(AppStrings.saveToWantToGo));
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
  });
}
