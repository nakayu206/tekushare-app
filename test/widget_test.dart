import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tekushare/app.dart';
import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/photo_repository.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

class _FakeSpotRepository implements SpotRepository {
  @override
  Stream<List<Spot>> getSpots() => const Stream.empty();
  @override
  Future<void> saveSpot(Spot spot) async {}
  @override
  Future<void> updateSpotStatus(String id, SpotStatus status) async {}
  @override
  Future<void> deleteSpot(String id) async {}
}

class _FakePhotoRepository implements PhotoRepository {
  @override
  Future<void> attachPhoto(String spotId, String imagePath) async {}
}

class _FakeWalkSessionRepository implements WalkSessionRepository {
  @override
  Future<void> saveSession(WalkSession session) async {}
  @override
  Future<List<WalkSession>> getAllSessions() async => [];
  @override
  Future<WalkSession?> getSessionById(String id) async => null;
}

class _FakeRouteRepository implements RouteRepository {
  @override
  Future<void> saveRoute(WalkRoute route) async {}
  @override
  Future<WalkRoute?> getRouteBySessionId(String sessionId) async => null;
  @override
  Future<List<WalkRoute>> getAllRoutes() async => [];
}

void main() {
  testWidgets('launches app and shows home screen', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AppConfig.setFlavor(Flavor.dev);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // DB初期化をスキップして即時解決
          appReadyProvider.overrideWith((ref) async {}),
          spotRepositoryProvider.overrideWithValue(_FakeSpotRepository()),
          photoRepositoryProvider.overrideWithValue(_FakePhotoRepository()),
          walkSessionRepositoryProvider
              .overrideWithValue(_FakeWalkSessionRepository()),
          routeRepositoryProvider.overrideWithValue(_FakeRouteRepository()),
        ],
        child: const TekuShareApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
  });
}
