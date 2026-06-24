import 'package:geolocator/geolocator.dart';

class LocationService {
  /// パーミッション確認・リクエストを行い、現在地の Stream を返す。
  /// パーミッションが拒否された場合は例外をスローする。
  Stream<Position> positionStream() async* {
    await _ensurePermission();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // 5m 以上移動したら更新
    );

    yield* Geolocator.getPositionStream(locationSettings: settings);
  }

  /// 現在地を一度だけ取得する。
  Future<Position> getCurrentPosition() async {
    await _ensurePermission();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<void> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(permission.toString());
    }
  }
}
