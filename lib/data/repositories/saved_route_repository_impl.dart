import 'package:isar/isar.dart';
import 'package:tekushare/data/models/saved_route_model.dart';
import 'package:tekushare/domain/entities/saved_route.dart';
import 'package:tekushare/domain/repositories/saved_route_repository.dart';

class SavedRouteRepositoryImpl implements SavedRouteRepository {
  SavedRouteRepositoryImpl(this._isar, this._userUid);

  final Isar _isar;
  final String _userUid;

  @override
  Future<void> save(SavedRoute route) async {
    await _isar.writeTxn(() async {
      await _isar.savedRouteModels
          .put(SavedRouteModel.fromEntity(route, _userUid));
    });
  }

  @override
  Future<List<SavedRoute>> getAll() async {
    final models = await _isar.savedRouteModels
        .filter()
        .userUidEqualTo(_userUid)
        .sortByCreatedAt()
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      final model = await _isar.savedRouteModels.get(id);
      if (model == null || model.userUid != _userUid) return;
      await _isar.savedRouteModels.delete(id);
    });
  }
}
