import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/usecases/walk/check_inactivity.dart';
import 'package:tekushare/infrastructure/notification_service.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

class InactivityNotifier extends StateNotifier<DateTime> {
  InactivityNotifier({required NotificationService notificationService})
      : _notificationService = notificationService,
        super(DateTime.now()) {
    _startTimer();
  }

  static const _checkInactivity = CheckInactivity();
  static const _checkInterval = Duration(minutes: 1);

  final NotificationService _notificationService;
  Timer? _timer;

  /// ユーザー操作が発生するたびに呼び出す
  void updateLastAction() {
    state = DateTime.now();
  }

  void _startTimer() {
    _timer = Timer.periodic(_checkInterval, (_) async {
      if (_checkInactivity.call(state)) {
        await _notificationService.showInactivityNotification();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final inactivityProvider =
    StateNotifierProvider<InactivityNotifier, DateTime>((ref) {
  return InactivityNotifier(
    notificationService: ref.watch(notificationServiceProvider),
  );
});
