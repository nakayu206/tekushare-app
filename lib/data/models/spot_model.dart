import 'package:isar/isar.dart';
import 'package:tekushare/domain/entities/spot.dart';

part 'spot_model.g.dart';

@Collection()
class SpotModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;
  late String title;
  late double latitude;
  late double longitude;

  @Enumerated(EnumType.name)
  late SpotStatus status;

  String? memo;
  List<String> photoPaths = [];
  late DateTime createdAt;

  Spot toEntity() {
    return Spot(
      id: uid,
      title: title,
      latitude: latitude,
      longitude: longitude,
      status: status,
      memo: memo,
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
      ..status = spot.status
      ..memo = spot.memo
      ..photoPaths = spot.photoPaths
      ..createdAt = spot.createdAt;
  }
}
