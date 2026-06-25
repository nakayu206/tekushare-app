import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';

class UpdateSpotStatus {
  const UpdateSpotStatus(this._repository);

  final SpotRepository _repository;

  Future<void> call(String spotId, SpotStatus status) {
    return _repository.updateSpotStatus(spotId, status);
  }
}
