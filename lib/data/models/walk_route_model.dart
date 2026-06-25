import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:tekushare/domain/entities/lat_lng.dart';
import 'package:tekushare/domain/entities/walk_route.dart';

part 'walk_route_model.g.dart';

@Collection()
class WalkRouteModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;

  @Index()
  late String walkSessionId;

  // List<LatLng> を JSON 文字列として保存
  late String pointsJson;

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

  static WalkRouteModel fromEntity(WalkRoute route) {
    final pointsJson = jsonEncode(
      route.points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    );

    return WalkRouteModel()
      ..uid = route.id
      ..walkSessionId = route.walkSessionId
      ..pointsJson = pointsJson
      ..createdAt = route.createdAt;
  }
}
