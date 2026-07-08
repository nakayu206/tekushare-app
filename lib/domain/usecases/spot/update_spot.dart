import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';

class UpdateSpot {
  const UpdateSpot(this._repository);

  final SpotRepository _repository;

  Future<void> call(Spot spot) => _repository.saveSpot(spot);
}
