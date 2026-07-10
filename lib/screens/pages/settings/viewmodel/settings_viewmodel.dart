import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void toggleEditSharedAccounts() => state = state.copyWith(
        isEditingSharedAccounts: !state.isEditingSharedAccounts,
      );

  Future<void> unlinkAccount(String uid) {
    return ref.read(accountLinkRepositoryProvider).unlink(uid);
  }

  Future<void> generateInviteLink() async {
    final link = await ref.read(accountLinkRepositoryProvider).createInviteLink();
    state = state.copyWith(inviteLink: link);
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
