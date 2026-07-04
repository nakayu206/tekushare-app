import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PhoneContact = ({String name, String phone});

class SettingsState {
  const SettingsState({
    this.timerEnabled = true,
    this.timerRoundTrip = true,
    this.timerMinutes = 30,
    this.inactivityEnabled = false,
    this.inactivityMinutes = 15,
    this.registeredContactName,
    this.shareWantToGo = true,
    this.shareVisited = true,
    this.sharedAccounts = const ['あかり', 'たかし', 'ゆか', 'けんじ'],
  });

  final bool timerEnabled;
  final bool timerRoundTrip;
  final int timerMinutes;
  final bool inactivityEnabled;
  final int inactivityMinutes;
  final String? registeredContactName;
  final bool shareWantToGo;
  final bool shareVisited;
  final List<String> sharedAccounts;

  SettingsState copyWith({
    bool? timerEnabled,
    bool? timerRoundTrip,
    int? timerMinutes,
    bool? inactivityEnabled,
    int? inactivityMinutes,
    String? registeredContactName,
    bool? shareWantToGo,
    bool? shareVisited,
    List<String>? sharedAccounts,
  }) =>
      SettingsState(
        timerEnabled: timerEnabled ?? this.timerEnabled,
        timerRoundTrip: timerRoundTrip ?? this.timerRoundTrip,
        timerMinutes: timerMinutes ?? this.timerMinutes,
        inactivityEnabled: inactivityEnabled ?? this.inactivityEnabled,
        inactivityMinutes: inactivityMinutes ?? this.inactivityMinutes,
        registeredContactName:
            registeredContactName ?? this.registeredContactName,
        shareWantToGo: shareWantToGo ?? this.shareWantToGo,
        shareVisited: shareVisited ?? this.shareVisited,
        sharedAccounts: sharedAccounts ?? this.sharedAccounts,
      );
}

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void setTimerEnabled(bool v) => state = state.copyWith(timerEnabled: v);
  void setTimerRoundTrip(bool v) => state = state.copyWith(timerRoundTrip: v);
  void setTimerMinutes(int v) => state = state.copyWith(timerMinutes: v);
  void setInactivityEnabled(bool v) =>
      state = state.copyWith(inactivityEnabled: v);
  void setInactivityMinutes(int v) =>
      state = state.copyWith(inactivityMinutes: v);
  void registerContact(String name) =>
      state = state.copyWith(registeredContactName: name);
  void setShareWantToGo(bool v) => state = state.copyWith(shareWantToGo: v);
  void setShareVisited(bool v) => state = state.copyWith(shareVisited: v);
  void removeSharedAccount(String name) {
    final updated = List<String>.from(state.sharedAccounts)..remove(name);
    state = state.copyWith(sharedAccounts: updated);
  }

  void logout() {}

  void deleteAccount() {}
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
