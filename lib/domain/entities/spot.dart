enum SpotStatus { wantToGo, visited }

class Spot {
  const Spot({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.memo,
    this.photoPath,
  });

  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final SpotStatus status;
  final String? memo;
  final String? photoPath;
  final DateTime createdAt;

  // memo / photoPath は null に戻せる必要があるためセンチネル値で未指定と明示的 null を区別する
  static const Object _sentinel = Object();

  Spot copyWith({
    String? id,
    String? title,
    double? latitude,
    double? longitude,
    SpotStatus? status,
    Object? memo = _sentinel,
    Object? photoPath = _sentinel,
    DateTime? createdAt,
  }) {
    return Spot(
      id: id ?? this.id,
      title: title ?? this.title,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      memo: memo == _sentinel ? this.memo : memo as String?,
      photoPath: photoPath == _sentinel ? this.photoPath : photoPath as String?,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Spot markAsVisited() => copyWith(status: SpotStatus.visited);

  Spot markAsWantToGo() => copyWith(status: SpotStatus.wantToGo);
}
