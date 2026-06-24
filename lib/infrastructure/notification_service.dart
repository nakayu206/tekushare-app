import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._(this._plugin);

  static final NotificationService instance =
      NotificationService._(FlutterLocalNotificationsPlugin());

  @visibleForTesting
  factory NotificationService.forTest(
    FlutterLocalNotificationsPlugin plugin,
  ) =>
      NotificationService._(plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'tekushare_walk';
  static const _channelName = '散歩通知';

  static const _idInactivity = 1; // 10分無動作の安否確認通知
  static const _idTurnaround = 2; // 15分折返し通知

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  /// 10分無動作時の安否確認通知を表示する
  Future<void> showInactivityNotification() async {
    await _plugin.show(
      id: _idInactivity,
      title: '大丈夫ですか？',
      body: '10分間動きがありません。散歩を続けていますか？',
      notificationDetails: _notificationDetails(),
    );
  }

  /// 15分折返し通知を表示する
  Future<void> showTurnaroundNotification() async {
    await _plugin.show(
      id: _idTurnaround,
      title: 'そろそろ折り返しましょう',
      body: '散歩を始めてから15分が経ちました。',
      notificationDetails: _notificationDetails(),
    );
  }

  /// 表示中の通知をすべてキャンセルする
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
}
