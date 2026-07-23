import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/usecases/walk/end_walk.dart';
import 'package:tekushare/domain/usecases/walk/start_walk.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

class WalkSessionNotifier extends StateNotifier<WalkSession> {
  WalkSessionNotifier(
      {required EndWalk endWalk, required SharedPreferences prefs})
      : _endWalk = endWalk,
        _prefs = prefs,
        super(_restore(prefs));

  static const _startWalk = StartWalk();
  final EndWalk _endWalk;
  final SharedPreferences _prefs;

  static const _kId = 'walk_id';
  static const _kStatus = 'walk_status';
  static const _kStartedAt = 'walk_started_at';
  static const _kElapsed = 'walk_elapsed';

  static WalkSession _restore(SharedPreferences prefs) {
    final id = prefs.getString(_kId);
    final statusIndex = prefs.getInt(_kStatus);
    if (id == null || statusIndex == null) {
      return const WalkSession(id: '', status: WalkStatus.idle);
    }
    final status = WalkStatus.values[statusIndex];
    if (status != WalkStatus.walking) {
      return const WalkSession(id: '', status: WalkStatus.idle);
    }
    final startedAtMs = prefs.getInt(_kStartedAt);
    final elapsed = prefs.getInt(_kElapsed) ?? 0;
    return WalkSession(
      id: id,
      status: status,
      startedAt: startedAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(startedAtMs)
          : null,
      elapsedSeconds: elapsed,
    );
  }

  void _persist(WalkSession session) {
    if (session.status == WalkStatus.walking) {
      _prefs.setString(_kId, session.id);
      _prefs.setInt(_kStatus, session.status.index);
      if (session.startedAt != null) {
        _prefs.setInt(_kStartedAt, session.startedAt!.millisecondsSinceEpoch);
      }
      _prefs.setInt(_kElapsed, session.elapsedSeconds);
    } else {
      _prefs.remove(_kId);
      _prefs.remove(_kStatus);
      _prefs.remove(_kStartedAt);
      _prefs.remove(_kElapsed);
    }
  }

  void startWalk() {
    final session = _startWalk.call();
    _persist(session);
    state = session;
  }

  Future<void> endWalk(WalkRoute route) async {
    if (state.status != WalkStatus.walking) return;
    final finished = await _endWalk.call(state, route);
    _persist(finished);
    state = finished;
  }

  void resetWalk() {
    const session = WalkSession(id: '', status: WalkStatus.idle);
    _persist(session);
    state = session;
  }
}

final walkSessionProvider =
    StateNotifierProvider<WalkSessionNotifier, WalkSession>((ref) {
  return WalkSessionNotifier(
    endWalk: EndWalk(
      ref.watch(walkSessionRepositoryProvider),
      ref.watch(routeRepositoryProvider),
    ),
    prefs: ref.watch(sharedPrefsProvider).requireValue,
  );
});
