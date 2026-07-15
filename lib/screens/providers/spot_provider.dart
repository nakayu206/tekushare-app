import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/usecases/photo/attach_photo_to_spot.dart';
import 'package:tekushare/domain/usecases/photo/remove_photo_from_spot.dart';
import 'package:tekushare/domain/usecases/spot/get_spots.dart';
import 'package:tekushare/domain/usecases/spot/save_spot.dart';
import 'package:tekushare/domain/usecases/spot/delete_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot.dart';
import 'package:tekushare/domain/usecases/spot/update_spot_status.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

class SpotNotifier extends StateNotifier<List<Spot>> {
  SpotNotifier({
    required SaveSpot saveSpot,
    required GetSpots getSpots,
    required UpdateSpot updateSpot,
    required UpdateSpotStatus updateSpotStatus,
    required DeleteSpot deleteSpot,
    required AttachPhotoToSpot attachPhotoToSpot,
    required RemovePhotoFromSpot removePhotoFromSpot,
  })  : _saveSpot = saveSpot,
        _updateSpot = updateSpot,
        _updateSpotStatus = updateSpotStatus,
        _deleteSpot = deleteSpot,
        _attachPhotoToSpot = attachPhotoToSpot,
        _removePhotoFromSpot = removePhotoFromSpot,
        super([]) {
    _subscription = getSpots.call().listen((spots) => state = spots);
  }

  final SaveSpot _saveSpot;
  final UpdateSpot _updateSpot;
  final UpdateSpotStatus _updateSpotStatus;
  final DeleteSpot _deleteSpot;
  final AttachPhotoToSpot _attachPhotoToSpot;
  final RemovePhotoFromSpot _removePhotoFromSpot;
  late final StreamSubscription<List<Spot>> _subscription;

  Future<String> saveSpot({
    required String title,
    required double latitude,
    required double longitude,
    String? memo,
    String? category,
    SpotStatus status = SpotStatus.wantToGo,
  }) {
    return _saveSpot.call(
      title: title,
      latitude: latitude,
      longitude: longitude,
      memo: memo,
      category: category,
      status: status,
    );
  }

  Future<void> updateSpot(Spot spot) {
    return _updateSpot.call(spot);
  }

  Future<void> updateStatus(String spotId, SpotStatus status) {
    return _updateSpotStatus.call(spotId, status);
  }

  Future<String> attachPhoto(String spotId, String imagePath) {
    return _attachPhotoToSpot.call(spotId, imagePath);
  }

  Future<void> removePhoto(String spotId, String imagePath) {
    return _removePhotoFromSpot.call(spotId, imagePath);
  }

  Future<void> deleteSpot(String spotId) {
    return _deleteSpot.call(spotId);
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
    updateSpot: UpdateSpot(spotRepo),
    updateSpotStatus: UpdateSpotStatus(spotRepo),
    deleteSpot: DeleteSpot(spotRepo),
    attachPhotoToSpot: AttachPhotoToSpot(photoRepo),
    removePhotoFromSpot: RemovePhotoFromSpot(photoRepo),
  );
});

/// 行きたい！ページで撮影した写真の一時パスリスト
final pendingPhotoProvider = StateProvider<List<String>>((ref) => []);

/// 現在選択中のステータスフィルタ（null = 全件、デフォルトは行きたい！）
final selectedSpotStatusProvider =
    StateProvider<SpotStatus?>((ref) => SpotStatus.wantToGo);

/// 現在選択中のカテゴリフィルタ（null = 全件）
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// ステータス・カテゴリでフィルタリングしたスポット一覧（新着順）
final filteredSpotsProvider = Provider<List<Spot>>((ref) {
  final spots = ref.watch(spotProvider);
  final statusFilter = ref.watch(selectedSpotStatusProvider);
  final categoryFilter = ref.watch(selectedCategoryProvider);

  var filtered = statusFilter == null
      ? [...spots]
      : spots.where((s) => s.status == statusFilter).toList();

  if (categoryFilter != null) {
    filtered = filtered.where((s) => s.category == categoryFilter).toList();
  }

  filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return filtered;
});
