import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';

class SaveSpot {
  const SaveSpot(this._repository);

  final SpotRepository _repository;

  Future<void> call({
    required String title,
    required double latitude,
    required double longitude,
    String? memo,
    SpotStatus status = SpotStatus.wantToGo,
  }) async {
    final now = DateTime.now();
    final spot = Spot(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      latitude: latitude,
      longitude: longitude,
      status: status,
      createdAt: now,
      memo: memo,
    );
    await _repository.saveSpot(spot);
  }
}
