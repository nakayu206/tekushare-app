import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/infrastructure/location_service.dart';
import 'package:tekushare/screens/providers/walk_session_provider.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// 歩行中のみ位置情報 Stream を購読する。
/// 非歩行中（idle / finished）は Stream.empty() を返す。
/// autoDispose により参照がなくなると自動でキャンセルされる。
final locationProvider = StreamProvider.autoDispose<Position>((ref) {
  final status = ref.watch(walkSessionProvider.select((s) => s.status));
  if (status != WalkStatus.walking) {
    return const Stream.empty();
  }
  return ref.watch(locationServiceProvider).positionStream();
});
