import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/repositories/route_repository.dart';
import 'package:tekushare/domain/repositories/walk_session_repository.dart';

class EndWalk {
  const EndWalk(this._sessionRepository, this._routeRepository);

  final WalkSessionRepository _sessionRepository;
  final RouteRepository _routeRepository;

  Future<WalkSession> call(WalkSession session, WalkRoute route) async {
    final now = DateTime.now();
    final elapsed = session.startedAt != null
        ? now.difference(session.startedAt!).inSeconds
        : 0;
    final finished = session.copyWith(
      status: WalkStatus.finished,
      finishedAt: now,
      elapsedSeconds: elapsed,
    );
    await _sessionRepository.saveSession(finished);
    await _routeRepository.saveRoute(route);
    return finished;
  }
}
