import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tekushare/infrastructure/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// 散歩中のみ有効化する位置情報 Stream。
/// autoDispose により画面を離れると自動でキャンセルされる。
final locationProvider = StreamProvider.autoDispose<Position>((ref) {
  return ref.watch(locationServiceProvider).positionStream();
});
