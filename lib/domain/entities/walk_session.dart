enum WalkStatus { idle, walking, finished }

class WalkSession {
  const WalkSession({
    required this.status,
    this.startedAt,
    this.finishedAt,
    this.elapsedSeconds = 0,
  });

  final WalkStatus status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int elapsedSeconds;

  WalkSession copyWith({
    WalkStatus? status,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? elapsedSeconds,
  }) {
    return WalkSession(
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
