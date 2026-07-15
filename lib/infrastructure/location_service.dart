import 'package:geolocator/geolocator.dart';

class LocationService {
  static const _distanceFilterMeters = 3;

  // 通常精度しきい値：これ以下の誤差のみ採用
  static const _maxAccuracyMeters = 20.0;

  // フォールバックしきい値：一定時間良好なポイントが来なければ緩和
  static const _fallbackAccuracyMeters = 50.0;
  static const _fallbackTimeout = Duration(seconds: 10);

  /// パーミッション確認・リクエストを行い、現在地の Stream を返す。
  /// パーミッションが拒否された場合は例外をスローする。
  Stream<Position> positionStream() async* {
    await _ensurePermission();

    // 散歩2回目以降は distanceFilter により getPositionStream が初回位置を配信しない
    // ため、キャッシュ済みの最終位置を先に配信してマップ・GPS インジケーターを即時更新する。
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && last.accuracy <= _fallbackAccuracyMeters) {
        yield last;
      }
    } catch (_) {}

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: _distanceFilterMeters,
    );

    DateTime? lastEmitted;
    await for (final pos
        in Geolocator.getPositionStream(locationSettings: settings)) {
      final now = DateTime.now();
      final prev = lastEmitted;
      final sinceLastEmit =
          prev == null ? _fallbackTimeout : now.difference(prev);
      if (pos.accuracy <= _maxAccuracyMeters ||
          sinceLastEmit >= _fallbackTimeout &&
              pos.accuracy <= _fallbackAccuracyMeters) {
        lastEmitted = now;
        yield pos;
      }
    }
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
