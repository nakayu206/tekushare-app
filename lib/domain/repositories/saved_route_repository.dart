import 'package:tekushare/domain/entities/saved_route.dart';

abstract interface class SavedRouteRepository {
  Future<void> save(SavedRoute route);
  Future<List<SavedRoute>> getAll();
}
