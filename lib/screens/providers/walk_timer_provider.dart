import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalkTimerState {
  const WalkTimerState({
    this.turnSecondsLeft,
    this.inactSecondsLeft,
    this.turnFired = false,
    this.inactFired = false,
    this.turnAlertShown = false,
    this.initialized = false,
  });

  final int? turnSecondsLeft;
  final int? inactSecondsLeft;
  final bool turnFired;
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
    required bool inactivityEnabled,
    required int inactivityMinutes,
  }) {
    if (state.initialized) return;
    state = WalkTimerState(
      turnSecondsLeft: timerEnabled ? timerMinutes * 60 : null,
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
      inactSecondsLeft: s.inactSecondsLeft != null && s.inactSecondsLeft! > 0
          ? s.inactSecondsLeft! - 1
          : s.inactSecondsLeft,
      turnFired: s.turnFired,
      inactFired: s.inactFired,
      turnAlertShown: s.turnAlertShown,
      initialized: s.initialized,
    );
  }

  void markTurnFired() {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: s.turnSecondsLeft,
      inactSecondsLeft: s.inactSecondsLeft,
      turnFired: true,
      inactFired: s.inactFired,
      turnAlertShown: s.turnAlertShown,
      initialized: s.initialized,
    );
  }

  void markInactFired() {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: s.turnSecondsLeft,
      inactSecondsLeft: s.inactSecondsLeft,
      turnFired: s.turnFired,
      inactFired: true,
      turnAlertShown: s.turnAlertShown,
      initialized: s.initialized,
    );
  }

  void markTurnAlertShown() {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: s.turnSecondsLeft,
      inactSecondsLeft: s.inactSecondsLeft,
      turnFired: s.turnFired,
      inactFired: s.inactFired,
      turnAlertShown: true,
      initialized: s.initialized,
    );
  }

  void resetTurn(int minutes) {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: minutes * 60,
      inactSecondsLeft: s.inactSecondsLeft,
      turnFired: false,
      inactFired: s.inactFired,
      turnAlertShown: false,
      initialized: s.initialized,
    );
  }

  void resetInact(int minutes) {
    final s = state;
    state = WalkTimerState(
      turnSecondsLeft: s.turnSecondsLeft,
      inactSecondsLeft: minutes * 60,
      turnFired: s.turnFired,
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
