import 'package:isar/isar.dart';
import 'package:tekushare/domain/entities/saved_route.dart';

part 'saved_route_model.g.dart';

@Collection()
class SavedRouteModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String date;
  late String distance;
  late String time;
  late DateTime createdAt;

  SavedRoute toEntity() => SavedRoute(
        id: id,
        name: name,
        date: date,
        distance: distance,
        time: time,
        createdAt: createdAt,
      );

  static SavedRouteModel fromEntity(SavedRoute route) {
    final model = SavedRouteModel()
      ..name = route.name
      ..date = route.date
      ..distance = route.distance
      ..time = route.time
      ..createdAt = route.createdAt;
    if (route.id != 0) model.id = route.id;
    return model;
  }
}
