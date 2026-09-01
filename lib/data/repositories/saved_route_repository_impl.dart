import 'package:objectbox/objectbox.dart';
import 'package:tekushare/data/models/saved_route_model.dart';
import 'package:tekushare/domain/entities/saved_route.dart';
import 'package:tekushare/domain/repositories/saved_route_repository.dart';
import 'package:tekushare/objectbox.g.dart';

class SavedRouteRepositoryImpl implements SavedRouteRepository {
  SavedRouteRepositoryImpl(Store store, this._userUid)
      : _box = store.box<SavedRouteModel>();

  final Box<SavedRouteModel> _box;
  final String _userUid;

  @override
  Future<void> save(SavedRoute route) async {
    _box.put(SavedRouteModel.fromEntity(route, _userUid));
  }

  @override
  Future<List<SavedRoute>> getAll() async {
    final models = (_box
            .query(SavedRouteModel_.userUid.equals(_userUid))
            .order(SavedRouteModel_.createdAt)
            .build()
            .find())
        .map((m) => m.toEntity())
        .toList();
    return models;
  }

  @override
  Future<void> delete(int id) async {
    final model = _box.get(id);
    if (model == null || model.userUid != _userUid) return;
    _box.remove(id);
  }
}
