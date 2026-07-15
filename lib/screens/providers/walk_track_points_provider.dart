import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' show Position;
import 'package:tekushare/domain/entities/lat_lng.dart' as domain;
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/screens/providers/location_provider.dart';
import 'package:tekushare/screens/providers/walk_session_provider.dart';

/// 散歩中に蓄積した GPS トラックポイントを保持するプロバイダー。
/// 散歩中でない場合は空リストを返し、散歩終了や別ページへの遷移があっても
/// ウォーキング中はデータが消えない。
class WalkTrackPointsNotifier extends Notifier<List<domain.LatLng>> {
  @override
  List<domain.LatLng> build() {
    final status = ref.watch(walkSessionProvider.select((s) => s.status));
    if (status != WalkStatus.walking) return [];

    // プロバイダー初期化時点で locationProvider がすでに GPS 位置を持っている場合
    // （FlutterMap が表示されてから本プロバイダーが初めてアクセスされるケース）は
    // キャッシュ値を初期点として取り込む。
    final cached = ref.read(locationProvider).valueOrNull;
    final initial = cached != null
        ? [domain.LatLng(cached.latitude, cached.longitude)]
        : <domain.LatLng>[];

    ref.listen<AsyncValue<Position>>(locationProvider, (_, next) {
      next.whenData((pos) {
        final p = domain.LatLng(pos.latitude, pos.longitude);
        // 初期点と重複する場合は追加しない
        if (state.isNotEmpty &&
            state.last.latitude == p.latitude &&
            state.last.longitude == p.longitude) {
          return;
        }
        state = [...state, p];
      });
    });

    return initial;
  }
}

final walkTrackPointsProvider =
    NotifierProvider<WalkTrackPointsNotifier, List<domain.LatLng>>(
  WalkTrackPointsNotifier.new,
);
