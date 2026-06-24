import 'package:tekushare/domain/entities/lat_lng.dart';

class WalkRoute {
  const WalkRoute({
    required this.id,
    required this.walkSessionId,
    required this.points,
    required this.createdAt,
  });

  final String id;
  final String walkSessionId;
  final List<LatLng> points;
  final DateTime createdAt;

  WalkRoute copyWith({
    String? id,
    String? walkSessionId,
    List<LatLng>? points,
    DateTime? createdAt,
  }) {
    return WalkRoute(
      id: id ?? this.id,
      walkSessionId: walkSessionId ?? this.walkSessionId,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
