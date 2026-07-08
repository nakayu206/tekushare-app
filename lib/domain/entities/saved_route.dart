class SavedRoute {
  const SavedRoute({
    required this.id,
    required this.name,
    required this.date,
    required this.distance,
    required this.time,
    required this.createdAt,
    this.walkSessionId,
  });

  final int id;
  final String name;
  final String date;
  final String distance;
  final String time;
  final DateTime createdAt;
  final String? walkSessionId;
}
