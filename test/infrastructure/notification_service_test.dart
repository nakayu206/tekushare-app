import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/infrastructure/notification_service.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late NotificationService service;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    service = NotificationService.forTest(mockPlugin);
  });

  group('NotificationService', () {
    test('initialize で plugin.initialize が呼ばれる', () async {
      when(mockPlugin.initialize(settings: anyNamed('settings')))
          .thenAnswer((_) async => true);

      await service.initialize();

      verify(mockPlugin.initialize(settings: anyNamed('settings'))).called(1);
    });

    test('showInactivityNotification で id=1 の通知が表示される', () async {
      when(
        mockPlugin.show(
          id: anyNamed('id'),
          title: anyNamed('title'),
          body: anyNamed('body'),
          notificationDetails: anyNamed('notificationDetails'),
        ),
      ).thenAnswer((_) async {});

      await service.showInactivityNotification();

      verify(
        mockPlugin.show(
          id: 1,
          title: anyNamed('title'),
          body: anyNamed('body'),
          notificationDetails: anyNamed('notificationDetails'),
        ),
      ).called(1);
    });

    test('showTurnaroundNotification で id=2 の通知が表示される', () async {
      when(
        mockPlugin.show(
          id: anyNamed('id'),
          title: anyNamed('title'),
          body: anyNamed('body'),
          notificationDetails: anyNamed('notificationDetails'),
        ),
      ).thenAnswer((_) async {});

      await service.showTurnaroundNotification();

      verify(
        mockPlugin.show(
          id: 2,
          title: anyNamed('title'),
          body: anyNamed('body'),
          notificationDetails: anyNamed('notificationDetails'),
        ),
      ).called(1);
    });

    test('cancelAll で plugin.cancelAll が呼ばれる', () async {
      when(mockPlugin.cancelAll()).thenAnswer((_) async {});

      await service.cancelAll();

      verify(mockPlugin.cancelAll()).called(1);
    });
  });
}
