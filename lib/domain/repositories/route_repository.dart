import 'package:tekushare/domain/entities/walk_route.dart';

abstract interface class RouteRepository {
  Future<void> saveRoute(WalkRoute route);
  Future<WalkRoute?> getRouteBySessionId(String sessionId);
  Future<List<WalkRoute>> getAllRoutes();
}
