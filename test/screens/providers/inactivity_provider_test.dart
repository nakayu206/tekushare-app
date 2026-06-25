import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tekushare/infrastructure/notification_service.dart';
import 'package:tekushare/screens/providers/app_providers.dart';
import 'package:tekushare/screens/providers/inactivity_provider.dart';

import 'inactivity_provider_test.mocks.dart';

@GenerateMocks([NotificationService])
void main() {
  late MockNotificationService mockNotification;

  setUp(() {
    mockNotification = MockNotificationService();
    when(mockNotification.showInactivityNotification())
        .thenAnswer((_) => Future<void>.value());
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        notificationServiceProvider.overrideWithValue(mockNotification),
      ],
    );
  }

  group('InactivityNotifier', () {
    test('初期状態は現在時刻付近', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final lastAction = container.read(inactivityProvider);
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(lastAction.isAfter(before), isTrue);
      expect(lastAction.isBefore(after), isTrue);
    });

    test('updateLastAction で lastActionAt が更新される', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final before = container.read(inactivityProvider);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      container.read(inactivityProvider.notifier).updateLastAction();
      final after = container.read(inactivityProvider);

      expect(after.isAfter(before), isTrue);
    });
  });
}
