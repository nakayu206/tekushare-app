import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tekushare/infrastructure/location_service.dart';

// GeolocatorPlatform は PlatformInterface の制約があるため、
// MockPlatformInterfaceMixin と明示的な noSuchMethod が必要。
class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() => super.noSuchMethod(
        Invocation.method(#isLocationServiceEnabled, []),
        returnValue: Future<bool>.value(false),
        returnValueForMissingStub: Future<bool>.value(false),
      ) as Future<bool>;

  @override
  Future<LocationPermission> checkPermission() => super.noSuchMethod(
        Invocation.method(#checkPermission, []),
        returnValue:
            Future<LocationPermission>.value(LocationPermission.denied),
        returnValueForMissingStub:
            Future<LocationPermission>.value(LocationPermission.denied),
      ) as Future<LocationPermission>;

  @override
  Future<LocationPermission> requestPermission() => super.noSuchMethod(
        Invocation.method(#requestPermission, []),
        returnValue:
            Future<LocationPermission>.value(LocationPermission.denied),
        returnValueForMissingStub:
            Future<LocationPermission>.value(LocationPermission.denied),
      ) as Future<LocationPermission>;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) =>
      super.noSuchMethod(
        Invocation.method(
          #getCurrentPosition,
          [],
          {#locationSettings: locationSettings},
        ),
        returnValue: Future<Position>.value(_dummyPosition()),
        returnValueForMissingStub: Future<Position>.value(_dummyPosition()),
      ) as Future<Position>;
}

Position _dummyPosition() => Position(
      latitude: 0,
      longitude: 0,
      timestamp: DateTime(2024),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  late MockGeolocatorPlatform mockPlatform;
  late LocationService service;

  setUp(() {
    final original = GeolocatorPlatform.instance;
    addTearDown(() => GeolocatorPlatform.instance = original);
    mockPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockPlatform;
    service = LocationService();
  });

  group('LocationService', () {
    test('位置情報サービスが無効な場合は例外をスローする', () async {
      when(mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      await expectLater(
        service.getCurrentPosition(),
        throwsA(isA<LocationServiceDisabledException>()),
      );
    });

    test('パーミッションが拒否された場合は例外をスローする', () async {
      when(mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      await expectLater(
        service.getCurrentPosition(),
        throwsA(isA<PermissionDeniedException>()),
      );
    });

    test('unableToDetermine の場合は requestPermission を呼び許可されれば通過する', () async {
      final expected = Position(
        latitude: 35.6812,
        longitude: 139.7671,
        timestamp: DateTime(2024, 1, 1),
        accuracy: 5.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      when(mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.unableToDetermine);
      when(mockPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(
        mockPlatform.getCurrentPosition(
          locationSettings: anyNamed('locationSettings'),
        ),
      ).thenAnswer((_) async => expected);

      final result = await service.getCurrentPosition();

      expect(result.latitude, 35.6812);
    });

    test('unableToDetermine で requestPermission も拒否された場合は例外をスローする', () async {
      when(mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.unableToDetermine);
      when(mockPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      await expectLater(
        service.getCurrentPosition(),
        throwsA(isA<PermissionDeniedException>()),
      );
    });

    test('パーミッションが永久拒否された場合は例外をスローする', () async {
      when(mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      await expectLater(
        service.getCurrentPosition(),
        throwsA(isA<PermissionDeniedException>()),
      );
    });

    test('パーミッションが許可されている場合は現在地を返す', () async {
      final expected = Position(
        latitude: 35.6812,
        longitude: 139.7671,
        timestamp: DateTime(2024, 1, 1),
        accuracy: 5.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      when(mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(
        mockPlatform.getCurrentPosition(
          locationSettings: anyNamed('locationSettings'),
        ),
      ).thenAnswer((_) async => expected);

      final result = await service.getCurrentPosition();

      expect(result.latitude, 35.6812);
      expect(result.longitude, 139.7671);
    });
  });
}
