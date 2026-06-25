import 'package:tekushare/domain/entities/walk_session.dart';

class StartWalk {
  const StartWalk();

  WalkSession call() {
    final now = DateTime.now();
    return WalkSession(
      id: now.microsecondsSinceEpoch.toString(),
      status: WalkStatus.walking,
      startedAt: now,
    );
  }
}
