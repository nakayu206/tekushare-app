import 'package:objectbox/objectbox.dart';
import 'package:tekushare/data/models/spot_model.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/domain/repositories/spot_repository.dart';
import 'package:tekushare/objectbox.g.dart';

class SpotRepositoryImpl implements SpotRepository {
  SpotRepositoryImpl(Store store) : _box = store.box<SpotModel>();

  final Box<SpotModel> _box;

  @override
  Future<void> saveSpot(Spot spot) async {
    final model = SpotModel.fromEntity(spot);
    final existing =
        _box.query(SpotModel_.uid.equals(spot.id)).build().findFirst();
    if (existing != null) model.id = existing.id;
    _box.put(model);
  }

  @override
  Stream<List<Spot>> getSpots() {
    return _box
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find().map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> updateSpotStatus(String id, SpotStatus status) async {
    final model = _box.query(SpotModel_.uid.equals(id)).build().findFirst();
    if (model == null) return;
    model.statusName = status.name;
    _box.put(model);
  }

  @override
  Future<void> deleteSpot(String id) async {
    final model = _box.query(SpotModel_.uid.equals(id)).build().findFirst();
    if (model == null) return;
    _box.remove(model.id);
  }
}
