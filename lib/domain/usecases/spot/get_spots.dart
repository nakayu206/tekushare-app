import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';

class GetSpots {
  const GetSpots(this._repository);

  final SpotRepository _repository;

  Stream<List<Spot>> call({SpotStatus? filter}) {
    return _repository.getSpots().map((spots) {
      if (filter == null) return spots;
      return spots.where((s) => s.status == filter).toList();
    });
  }
}
