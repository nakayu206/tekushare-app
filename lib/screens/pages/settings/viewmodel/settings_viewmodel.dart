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
    this.shareSpots = false,
    this.shareRoutes = false,
  });

  final bool timerEnabled;
  final bool timerRoundTrip;
  final int timerMinutes;
  final bool inactivityEnabled;
  final int inactivityMinutes;
  final String? registeredContactName;
  final bool shareSpots;
  final bool shareRoutes;

  SettingsState copyWith({
    bool? timerEnabled,
    bool? timerRoundTrip,
    int? timerMinutes,
    bool? inactivityEnabled,
    int? inactivityMinutes,
    String? registeredContactName,
    bool? shareSpots,
    bool? shareRoutes,
  }) =>
      SettingsState(
        timerEnabled: timerEnabled ?? this.timerEnabled,
        timerRoundTrip: timerRoundTrip ?? this.timerRoundTrip,
        timerMinutes: timerMinutes ?? this.timerMinutes,
        inactivityEnabled: inactivityEnabled ?? this.inactivityEnabled,
        inactivityMinutes: inactivityMinutes ?? this.inactivityMinutes,
        registeredContactName:
            registeredContactName ?? this.registeredContactName,
        shareSpots: shareSpots ?? this.shareSpots,
        shareRoutes: shareRoutes ?? this.shareRoutes,
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
  void setShareSpots(bool v) => state = state.copyWith(shareSpots: v);
  void setShareRoutes(bool v) => state = state.copyWith(shareRoutes: v);
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
