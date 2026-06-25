import 'package:isar/isar.dart';
import 'package:tekushare/data/models/walk_route_model.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<void> saveRoute(WalkRoute route) async {
    await _isar.writeTxn(() async {
      await _isar.walkRouteModels.putByUid(WalkRouteModel.fromEntity(route));
    });
  }

  @override
  Future<WalkRoute?> getRouteBySessionId(String sessionId) async {
    final model = await _isar.walkRouteModels
        .where()
        .walkSessionIdEqualTo(sessionId)
        .findFirst();
    return model?.toEntity();
  }

  @override
  Future<List<WalkRoute>> getAllRoutes() async {
    final models = await _isar.walkRouteModels.where().findAll();
    return models.map((m) => m.toEntity()).toList();
  }
}
