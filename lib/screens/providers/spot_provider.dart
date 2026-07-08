import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/usecases/photo/attach_photo_to_spot.dart';
import 'package:tekushare/domain/usecases/photo/remove_photo_from_spot.dart';
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
    required RemovePhotoFromSpot removePhotoFromSpot,
  })  : _saveSpot = saveSpot,
        _updateSpotStatus = updateSpotStatus,
        _attachPhotoToSpot = attachPhotoToSpot,
        _removePhotoFromSpot = removePhotoFromSpot,
        super([]) {
    _subscription = getSpots.call().listen((spots) => state = spots);
  }

  final SaveSpot _saveSpot;
  final UpdateSpotStatus _updateSpotStatus;
  final AttachPhotoToSpot _attachPhotoToSpot;
  final RemovePhotoFromSpot _removePhotoFromSpot;
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

  Future<void> removePhoto(String spotId, String imagePath) {
    return _removePhotoFromSpot.call(spotId, imagePath);
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
    removePhotoFromSpot: RemovePhotoFromSpot(photoRepo),
  );
});

/// 行きたい！ページで撮影した写真の一時パスリスト
final pendingPhotoProvider = StateProvider<List<String>>((ref) => []);

/// 現在選択中のステータスフィルタ（null = 全件、デフォルトは行きたい！）
final selectedSpotStatusProvider =
    StateProvider<SpotStatus?>((ref) => SpotStatus.wantToGo);

/// selectedSpotStatusProvider と連動してフィルタリングしたスポット一覧（新着順）
final filteredSpotsProvider = Provider<List<Spot>>((ref) {
  final spots = ref.watch(spotProvider);
  final filter = ref.watch(selectedSpotStatusProvider);
  final filtered = filter == null
      ? [...spots]
      : spots.where((s) => s.status == filter).toList();
  filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return filtered;
});
