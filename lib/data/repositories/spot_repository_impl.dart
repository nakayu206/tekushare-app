import 'package:isar/isar.dart';
import 'package:tekushare/data/models/spot_model.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';

class SpotRepositoryImpl implements SpotRepository {
  SpotRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<void> saveSpot(Spot spot) async {
    await _isar.writeTxn(() async {
      await _isar.spotModels.putByUid(SpotModel.fromEntity(spot));
    });
  }

  @override
  Stream<List<Spot>> getSpots() {
    return _isar.spotModels
        .where()
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> updateSpotStatus(String id, SpotStatus status) async {
    await _isar.writeTxn(() async {
      final model = await _isar.spotModels.getByUid(id);
      if (model == null) return;
      model.status = status;
      await _isar.spotModels.put(model);
    });
  }

  @override
  Future<void> deleteSpot(String id) async {
    await _isar.writeTxn(() async {
      await _isar.spotModels.deleteByUid(id);
    });
  }
}
