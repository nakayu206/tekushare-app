import 'package:isar/isar.dart';
import 'package:tekushare/data/models/walk_route_model.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl(this._isar, this._userUid);

  final Isar _isar;
  final String _userUid;

  @override
  Future<void> saveRoute(WalkRoute route) async {
    await _isar.writeTxn(() async {
      await _isar.walkRouteModels
          .putByWalkSessionId(WalkRouteModel.fromEntity(route, _userUid));
    });
  }

  @override
  Future<WalkRoute?> getRouteBySessionId(String sessionId) async {
    final model = await _isar.walkRouteModels.getByWalkSessionId(sessionId);
    return model?.toEntity();
  }

  @override
  Future<List<WalkRoute>> getAllRoutes() async {
    final models =
        await _isar.walkRouteModels.filter().userUidEqualTo(_userUid).findAll();
    return models.map((m) => m.toEntity()).toList();
  }
}
