import 'package:tekushare/domain/repositories/spot_repository.dart';

class DeleteSpot {
  DeleteSpot(this._repo);

  final SpotRepository _repo;

  Future<void> call(String id) => _repo.deleteSpot(id);
}
