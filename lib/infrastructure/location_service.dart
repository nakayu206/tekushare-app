import 'package:geolocator/geolocator.dart';

class LocationService {
  static const _distanceFilterMeters = 3;

  // これより精度が低い（誤差が大きい）GPSポイントは捨てる
  static const _maxAccuracyMeters = 20.0;

  /// パーミッション確認・リクエストを行い、現在地の Stream を返す。
  /// パーミッションが拒否された場合は例外をスローする。
  Stream<Position> positionStream() async* {
    await _ensurePermission();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: _distanceFilterMeters,
    );

    yield* Geolocator.getPositionStream(locationSettings: settings)
        .where((pos) => pos.accuracy <= _maxAccuracyMeters);
  }

  /// 現在地を一度だけ取得する。
  Future<Position> getCurrentPosition() async {
    await _ensurePermission();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
  }

  Future<void> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(permission.toString());
    }
  }
}
