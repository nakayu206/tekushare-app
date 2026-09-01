import 'package:objectbox/objectbox.dart';
import 'package:tekushare/domain/entities/spot.dart';

@Entity()
class SpotModel {
  @Id()
  int id = 0;

  @Index()
  @Unique()
  late String uid;

  late String title;
  late double latitude;
  late double longitude;
  late String statusName;
  String? memo;
  String? category;

  @Property()
  List<String> photoPaths = [];

  @Property(type: PropertyType.date)
  late DateTime createdAt;

  Spot toEntity() {
    return Spot(
      id: uid,
      title: title,
      latitude: latitude,
      longitude: longitude,
      status: SpotStatus.values.firstWhere(
        (e) => e.name == statusName,
        orElse: () => SpotStatus.visited,
      ),
      memo: memo,
      category: category,
      photoPaths: photoPaths,
      createdAt: createdAt,
    );
  }

  static SpotModel fromEntity(Spot spot) {
    return SpotModel()
      ..uid = spot.id
      ..title = spot.title
      ..latitude = spot.latitude
      ..longitude = spot.longitude
      ..statusName = spot.status.name
      ..memo = spot.memo
      ..category = spot.category
      ..photoPaths = spot.photoPaths
      ..createdAt = spot.createdAt;
  }
}
