import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:tekushare/domain/entities/lat_lng.dart';
import 'package:tekushare/domain/entities/walk_route.dart';

@Entity()
class WalkRouteModel {
  @Id()
  int id = 0;

  @Index()
  @Unique()
  late String uid;

  @Index()
  @Unique()
  late String walkSessionId;

  @Index()
  String userUid = '';

  late String pointsJson;

  @Property(type: PropertyType.date)
  late DateTime createdAt;

  WalkRoute toEntity() {
    final decoded = jsonDecode(pointsJson) as List<dynamic>;
    final points = decoded
        .map((e) => LatLng(
              (e['lat'] as num).toDouble(),
              (e['lng'] as num).toDouble(),
            ))
        .toList();

    return WalkRoute(
      id: uid,
      walkSessionId: walkSessionId,
      points: points,
      createdAt: createdAt,
    );
  }

  static WalkRouteModel fromEntity(WalkRoute route, String userUid) {
    final json = jsonEncode(
      route.points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    );

    return WalkRouteModel()
      ..uid = route.id
      ..walkSessionId = route.walkSessionId
      ..userUid = userUid
      ..pointsJson = json
      ..createdAt = route.createdAt;
  }
}
