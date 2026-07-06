import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/usecases/photo/attach_photo_to_spot.dart';
import 'package:tekushare/domain/usecases/spot/get_spots.dart';
import 'package:tekushare/domain/usecases/spot/save_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot_status.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

class SpotNotifier extends StateNotifier<List<Spot>> {
  SpotNotifier({
    required SaveSpot saveSpot,
    required GetSpots getSpots,
    required UpdateSpotStatus updateSpotStatus,
    required AttachPhotoToSpot attachPhotoToSpot,
  })  : _saveSpot = saveSpot,
        _updateSpotStatus = updateSpotStatus,
        _attachPhotoToSpot = attachPhotoToSpot,
        super([]) {
    _subscription = getSpots.call().listen((spots) => state = spots);
  }

  final SaveSpot _saveSpot;
  final UpdateSpotStatus _updateSpotStatus;
  final AttachPhotoToSpot _attachPhotoToSpot;
  late final StreamSubscription<List<Spot>> _subscription;

  Future<String> saveSpot({
    required String title,
    required double latitude,
    required double longitude,
    String? memo,
    SpotStatus status = SpotStatus.wantToGo,
  }) {
    return _saveSpot.call(
      title: title,
      latitude: latitude,
      longitude: longitude,
      memo: memo,
      status: status,
    );
  }

  Future<void> updateStatus(String spotId, SpotStatus status) {
    return _updateSpotStatus.call(spotId, status);
  }

  Future<void> attachPhoto(String spotId, String imagePath) {
    return _attachPhotoToSpot.call(spotId, imagePath);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final spotProvider = StateNotifierProvider<SpotNotifier, List<Spot>>((ref) {
  final spotRepo = ref.watch(spotRepositoryProvider);
  final photoRepo = ref.watch(photoRepositoryProvider);
  return SpotNotifier(
    saveSpot: SaveSpot(spotRepo),
    getSpots: GetSpots(spotRepo),
    updateSpotStatus: UpdateSpotStatus(spotRepo),
    attachPhotoToSpot: AttachPhotoToSpot(photoRepo),
  );
});

/// 散歩中にカメラで撮影した写真の一時パス（WantToGoPage で使用）
final pendingPhotoProvider = StateProvider<String?>((ref) => null);

/// 現在選択中のステータスフィルタ（null = 全件、デフォルトは行きたい！）
final selectedSpotStatusProvider =
    StateProvider<SpotStatus?>((ref) => SpotStatus.wantToGo);

/// selectedSpotStatusProvider と連動してフィルタリングしたスポット一覧
final filteredSpotsProvider = Provider<List<Spot>>((ref) {
  final spots = ref.watch(spotProvider);
  final filter = ref.watch(selectedSpotStatusProvider);
  if (filter == null) return spots;
  return spots.where((s) => s.status == filter).toList();
});
