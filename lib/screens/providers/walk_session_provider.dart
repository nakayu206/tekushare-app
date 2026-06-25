import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/usecases/walk/end_walk.dart';
import 'package:tekushare/domain/usecases/walk/start_walk.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

class WalkSessionNotifier extends StateNotifier<WalkSession> {
  WalkSessionNotifier({required EndWalk endWalk})
      : _endWalk = endWalk,
        super(const WalkSession(id: '', status: WalkStatus.idle));

  static const _startWalk = StartWalk();
  final EndWalk _endWalk;

  void startWalk() {
    state = _startWalk.call();
  }

  Future<void> endWalk(WalkRoute route) async {
    final finished = await _endWalk.call(state, route);
    state = finished;
  }
}

final walkSessionProvider =
    StateNotifierProvider<WalkSessionNotifier, WalkSession>((ref) {
  return WalkSessionNotifier(
    endWalk: EndWalk(
      ref.watch(walkSessionRepositoryProvider),
      ref.watch(routeRepositoryProvider),
    ),
  );
});
