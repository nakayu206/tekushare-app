import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';

class SaveSpot {
  const SaveSpot(this._repository);

  final SpotRepository _repository;

  Future<String> call({
    required String title,
    required double latitude,
    required double longitude,
    String? memo,
    String? category,
    SpotStatus status = SpotStatus.wantToGo,
  }) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    final spot = Spot(
      id: id,
      title: title,
      latitude: latitude,
      longitude: longitude,
      status: status,
      createdAt: now,
      memo: memo,
      category: category,
    );
    await _repository.saveSpot(spot);
    return id;
  }
}
