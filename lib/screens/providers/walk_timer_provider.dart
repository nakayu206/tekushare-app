import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalkTimerState {
  const WalkTimerState({
    this.turnSecondsLeft,
    this.midpointSeconds,
    this.inactSecondsLeft,
    this.turnFired = false,
    this.midpointFired = false,
    this.inactFired = false,
    this.turnAlertShown = false,
    this.initialized = false,
  });

  final int? turnSecondsLeft;

  /// 往復モード時に折り返し通知を出す残り秒数（全体の半分）
  final int? midpointSeconds;
  final int? inactSecondsLeft;
  final bool turnFired;
  final bool midpointFired;
  final bool inactFired;
  final bool turnAlertShown;
  final bool initialized;
}

class WalkTimerNotifier extends StateNotifier<WalkTimerState> {
  WalkTimerNotifier() : super(const WalkTimerState());

  // 未初期化時のみ設定する（WalkPage 再生成でもリセットしない）
  void initializeIfNeeded({
    required bool timerEnabled,
    required int timerMinutes,
    required bool timerRoundTrip,
    required bool inactivityEnabled,
    required int inactivityMinutes,
  }) {
    if (state.initialized) return;
    final totalSeconds = timerEnabled ? timerMinutes * 60 : null;
    state = WalkTimerState(
      turnSecondsLeft: totalSeconds,
      midpointSeconds:
          totalSeconds != null && timerRoundTrip ? totalSeconds ~/ 2 : null,
      inactSecondsLeft: inactivityEnabled ? inactivityMinutes * 60 : null,
      initialized: true,
    );
  }

  void tick() {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: s.turnSecondsLeft != null && s.turnSecondsLeft! > 0
          ? s.turnSecondsLeft! - 1
          : s.turnSecondsLeft,
      midpointSeconds: s.midpointSeconds,
      inactSecondsLeft: s.inactSecondsLeft != null && s.inactSecondsLeft! > 0
          ? s.inactSecondsLeft! - 1
          : s.inactSecondsLeft,
      turnFired: s.turnFired,
      midpointFired: s.midpointFired,
      inactFired: s.inactFired,
      turnAlertShown: s.turnAlertShown,
      initialized: s.initialized,
    );
  }

  void markTurnFired() {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: s.turnSecondsLeft,
      midpointSeconds: s.midpointSeconds,
      inactSecondsLeft: s.inactSecondsLeft,
      turnFired: true,
      midpointFired: s.midpointFired,
      inactFired: s.inactFired,
      turnAlertShown: s.turnAlertShown,
      initialized: s.initialized,
    );
  }

  void markMidpointFired() {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: s.turnSecondsLeft,
      midpointSeconds: s.midpointSeconds,
      inactSecondsLeft: s.inactSecondsLeft,
      turnFired: s.turnFired,
      midpointFired: true,
      inactFired: s.inactFired,
      turnAlertShown: s.turnAlertShown,
      initialized: s.initialized,
    );
  }

  void markInactFired() {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: s.turnSecondsLeft,
      midpointSeconds: s.midpointSeconds,
      inactSecondsLeft: s.inactSecondsLeft,
      turnFired: s.turnFired,
      midpointFired: s.midpointFired,
      inactFired: true,
      turnAlertShown: s.turnAlertShown,
      initialized: s.initialized,
    );
  }

  void markTurnAlertShown() {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: s.turnSecondsLeft,
      midpointSeconds: s.midpointSeconds,
      inactSecondsLeft: s.inactSecondsLeft,
      turnFired: s.turnFired,
      midpointFired: s.midpointFired,
      inactFired: s.inactFired,
      turnAlertShown: true,
      initialized: s.initialized,
    );
  }

  void resetTurn(int minutes) {
    final s = state;
    final totalSeconds = minutes * 60;
    state = WalkTimerState(
      turnSecondsLeft: totalSeconds,
      midpointSeconds: s.midpointSeconds != null ? totalSeconds ~/ 2 : null,
      inactSecondsLeft: s.inactSecondsLeft,
      turnFired: false,
      midpointFired: false,
      inactFired: s.inactFired,
      turnAlertShown: false,
      initialized: s.initialized,
    );
  }

  void resetInact(int minutes) {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: s.turnSecondsLeft,
      midpointSeconds: s.midpointSeconds,
      inactSecondsLeft: minutes * 60,
      turnFired: s.turnFired,
      midpointFired: s.midpointFired,
      inactFired: false,
      turnAlertShown: s.turnAlertShown,
      initialized: s.initialized,
    );
  }

  void reset() => state = const WalkTimerState();
}

final walkTimerProvider =
    StateNotifierProvider<WalkTimerNotifier, WalkTimerState>(
  (ref) => WalkTimerNotifier(),
);
