import 'package:objectbox/objectbox.dart';
import 'package:tekushare/data/models/walk_route_model.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/objectbox.g.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl(Store store, this._userUid)
      : _box = store.box<WalkRouteModel>();

  final Box<WalkRouteModel> _box;
  final String _userUid;

  @override
  Future<void> saveRoute(WalkRoute route) async {
    final model = WalkRouteModel.fromEntity(route, _userUid);
    final existing = _box
        .query(WalkRouteModel_.walkSessionId.equals(route.walkSessionId))
        .build()
        .findFirst();
    if (existing != null) model.id = existing.id;
    _box.put(model);
  }

  @override
  Future<WalkRoute?> getRouteBySessionId(String sessionId) async {
    final model = _box
        .query(WalkRouteModel_.walkSessionId.equals(sessionId))
        .build()
        .findFirst();
    if (model == null || model.userUid != _userUid) return null;
    return model.toEntity();
  }

  @override
  Future<List<WalkRoute>> getAllRoutes() async {
    final models =
        _box.query(WalkRouteModel_.userUid.equals(_userUid)).build().find();
    return models.map((m) => m.toEntity()).toList();
  }
}
