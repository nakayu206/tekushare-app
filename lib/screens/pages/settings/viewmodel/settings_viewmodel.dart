import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

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
    this.inviteLink,
    this.isEditingSharedAccounts = false,
  });

  final bool timerEnabled;
  final bool timerRoundTrip;
  final int timerMinutes;
  final bool inactivityEnabled;
  final int inactivityMinutes;
  final String? registeredContactName;
  final bool shareWantToGo;
  final bool shareVisited;
  final String? inviteLink;
  final bool isEditingSharedAccounts;

  SettingsState copyWith({
    bool? timerEnabled,
    bool? timerRoundTrip,
    int? timerMinutes,
    bool? inactivityEnabled,
    int? inactivityMinutes,
    String? registeredContactName,
    bool? shareWantToGo,
    bool? shareVisited,
    String? inviteLink,
    bool? isEditingSharedAccounts,
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
        inviteLink: inviteLink ?? this.inviteLink,
        isEditingSharedAccounts:
            isEditingSharedAccounts ?? this.isEditingSharedAccounts,
      );
}

class SettingsViewModel extends Notifier<SettingsState> {
  static const _kTimerEnabled = 'settings_timerEnabled';
  static const _kTimerRoundTrip = 'settings_timerRoundTrip';
  static const _kTimerMinutes = 'settings_timerMinutes';
  static const _kInactivityEnabled = 'settings_inactivityEnabled';
  static const _kInactivityMinutes = 'settings_inactivityMinutes';
  static const _kRegisteredContactName = 'settings_registeredContactName';
  static const _kShareWantToGo = 'settings_shareWantToGo';
  static const _kShareVisited = 'settings_shareVisited';

  @override
  SettingsState build() {
    final prefsAsync = ref.watch(sharedPrefsProvider);
    return prefsAsync.when(
      data: (prefs) => SettingsState(
        timerEnabled: prefs.getBool(_kTimerEnabled) ?? true,
        timerRoundTrip: prefs.getBool(_kTimerRoundTrip) ?? true,
        timerMinutes: prefs.getInt(_kTimerMinutes) ?? 30,
        inactivityEnabled: prefs.getBool(_kInactivityEnabled) ?? false,
        inactivityMinutes: prefs.getInt(_kInactivityMinutes) ?? 15,
        registeredContactName: prefs.getString(_kRegisteredContactName),
        shareWantToGo: prefs.getBool(_kShareWantToGo) ?? true,
        shareVisited: prefs.getBool(_kShareVisited) ?? true,
      ),
      loading: () => const SettingsState(),
      error: (_, __) => const SettingsState(),
    );
  }

  SharedPreferences get _prefs => ref.read(sharedPrefsProvider).requireValue;

  void setTimerEnabled(bool v) {
    _prefs.setBool(_kTimerEnabled, v);
    state = state.copyWith(timerEnabled: v);
  }

  void setTimerRoundTrip(bool v) {
    _prefs.setBool(_kTimerRoundTrip, v);
    state = state.copyWith(timerRoundTrip: v);
  }

  void setTimerMinutes(int v) {
    _prefs.setInt(_kTimerMinutes, v);
    state = state.copyWith(timerMinutes: v);
  }

  void setInactivityEnabled(bool v) {
    _prefs.setBool(_kInactivityEnabled, v);
    state = state.copyWith(inactivityEnabled: v);
  }

  void setInactivityMinutes(int v) {
    _prefs.setInt(_kInactivityMinutes, v);
    state = state.copyWith(inactivityMinutes: v);
  }

  void registerContact(String name) {
    _prefs.setString(_kRegisteredContactName, name);
    state = state.copyWith(registeredContactName: name);
  }

  Future<void> setShareWantToGo(bool v) async {
    final prev = state.shareWantToGo;
    _prefs.setBool(_kShareWantToGo, v);
    state = state.copyWith(shareWantToGo: v);
    try {
      await ref.read(accountLinkRepositoryProvider).updateShareSettings(
            shareWantToGo: v,
            shareVisited: state.shareVisited,
          );
    } catch (_) {
      _prefs.setBool(_kShareWantToGo, prev);
      state = state.copyWith(shareWantToGo: prev);
    }
  }

  Future<void> setShareVisited(bool v) async {
    final prev = state.shareVisited;
    _prefs.setBool(_kShareVisited, v);
    state = state.copyWith(shareVisited: v);
    try {
      await ref.read(accountLinkRepositoryProvider).updateShareSettings(
            shareWantToGo: state.shareWantToGo,
            shareVisited: v,
          );
    } catch (_) {
      _prefs.setBool(_kShareVisited, prev);
      state = state.copyWith(shareVisited: prev);
    }
  }

  void toggleEditSharedAccounts() => state = state.copyWith(
        isEditingSharedAccounts: !state.isEditingSharedAccounts,
      );

  Future<void> unlinkAccount(String uid) {
    return ref.read(accountLinkRepositoryProvider).unlink(uid);
  }

  Future<void> generateInviteLink() async {
    final link =
        await ref.read(accountLinkRepositoryProvider).createInviteLink();
    state = state.copyWith(inviteLink: link);
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
