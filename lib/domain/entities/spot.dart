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
    this.photoPaths = const [],
  });

  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final SpotStatus status;
  final String? memo;
  final List<String> photoPaths;
  final DateTime createdAt;

  static const Object _sentinel = Object();

  Spot copyWith({
    String? id,
    String? title,
    double? latitude,
    double? longitude,
    SpotStatus? status,
    Object? memo = _sentinel,
    List<String>? photoPaths,
    DateTime? createdAt,
  }) {
    return Spot(
      id: id ?? this.id,
      title: title ?? this.title,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      memo: memo == _sentinel ? this.memo : memo as String?,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Spot markAsVisited() => copyWith(status: SpotStatus.visited);

  Spot markAsWantToGo() => copyWith(status: SpotStatus.wantToGo);
}
