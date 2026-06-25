import 'package:tekushare/domain/entities/spot.dart';

abstract interface class SpotRepository {
  Future<void> saveSpot(Spot spot);
  Stream<List<Spot>> getSpots();
  Future<void> updateSpotStatus(String id, SpotStatus status);
  Future<void> deleteSpot(String id);
}
