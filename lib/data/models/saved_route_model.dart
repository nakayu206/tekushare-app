import 'package:objectbox/objectbox.dart';
import 'package:tekushare/domain/entities/saved_route.dart';

@Entity()
class SavedRouteModel {
  @Id()
  int id = 0;

  @Index()
  String userUid = '';

  late String name;
  late String date;
  late String distance;
  late String time;

  @Property(type: PropertyType.date)
  late DateTime createdAt;

  String? walkSessionId;

  SavedRoute toEntity() => SavedRoute(
        id: id,
        name: name,
        date: date,
        distance: distance,
        time: time,
        createdAt: createdAt,
        walkSessionId: walkSessionId,
      );

  static SavedRouteModel fromEntity(SavedRoute route, String userUid) {
    final model = SavedRouteModel()
      ..userUid = userUid
      ..name = route.name
      ..date = route.date
      ..distance = route.distance
      ..time = route.time
      ..createdAt = route.createdAt
      ..walkSessionId = route.walkSessionId;
    if (route.id != 0) model.id = route.id;
    return model;
  }
}
