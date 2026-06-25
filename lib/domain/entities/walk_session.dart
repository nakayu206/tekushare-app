enum WalkStatus { idle, walking, finished }

class WalkSession {
  const WalkSession({
    required this.id,
    required this.status,
    this.startedAt,
    this.finishedAt,
    this.elapsedSeconds = 0,
  });

  final String id;
  final WalkStatus status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int elapsedSeconds;

  // startedAt / finishedAt は null に戻せる必要があるためセンチネル値で未指定と明示的 null を区別する
  static const Object _sentinel = Object();

  WalkSession copyWith({
    String? id,
    WalkStatus? status,
    Object? startedAt = _sentinel,
    Object? finishedAt = _sentinel,
    int? elapsedSeconds,
  }) {
    return WalkSession(
      id: id ?? this.id,
      status: status ?? this.status,
      startedAt:
          startedAt == _sentinel ? this.startedAt : startedAt as DateTime?,
      finishedAt:
          finishedAt == _sentinel ? this.finishedAt : finishedAt as DateTime?,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
