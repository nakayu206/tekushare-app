import 'package:isar/isar.dart';
import 'package:tekushare/data/models/saved_route_model.dart';
import 'package:tekushare/domain/entities/saved_route.dart';
import 'package:tekushare/domain/repositories/saved_route_repository.dart';

class SavedRouteRepositoryImpl implements SavedRouteRepository {
  SavedRouteRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<void> save(SavedRoute route) async {
    await _isar.writeTxn(() async {
      await _isar.savedRouteModels.put(SavedRouteModel.fromEntity(route));
    });
  }

  @override
  Future<List<SavedRoute>> getAll() async {
    final models =
        await _isar.savedRouteModels.where().sortByCreatedAt().findAll();
    return models.map((m) => m.toEntity()).toList();
  }
}
