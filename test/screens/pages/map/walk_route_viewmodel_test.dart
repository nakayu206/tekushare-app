import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/screens/pages/map/viewmodel/walk_route_viewmodel.dart';

void main() {
  group('WalkRouteViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    WalkRouteState state() => container.read(walkRouteViewModelProvider);
    WalkRouteViewModel vm() =>
        container.read(walkRouteViewModelProvider.notifier);

    // selectDay で selectedDay が更新される
    test('selectDay updates selectedDay', () {
      vm().selectDay(3);
      expect(state().selectedDay, 3);
    });

    // selectDay で selectedRouteIndex に影響しない
    test('selectDay does not affect selectedRouteIndex', () {
      final before = state().selectedRouteIndex;
      vm().selectDay(5);
      expect(state().selectedRouteIndex, before);
    });

    // saveRoute で walkSessionId が保持される
    test('saveRoute preserves walkSessionId', () {
      const item = (
        date: '2026/02/07',
        name: 'GPSコース',
        distance: '2.0km',
        time: '00:30',
        walkSessionId: 'session-xyz',
      );
      vm().saveRoute(item);

      expect(state().routes.last.walkSessionId, 'session-xyz');
    });

    // saveRoute で walkSessionId が null の場合も保持される
    test('saveRoute preserves null walkSessionId', () {
      const item = (
        date: '2026/02/08',
        name: 'テストコース',
        distance: '1.0km',
        time: '00:15',
        walkSessionId: null,
      );
      vm().saveRoute(item);

      expect(state().routes.last.walkSessionId, isNull);
    });

    // setRoutes で walkSessionId が保持される
    test('setRoutes preserves walkSessionId in all items', () {
      final routes = [
        (
          date: '2/1',
          name: 'A',
          distance: '1.0km',
          time: '15分',
          walkSessionId: 'session-1',
        ),
        (
          date: '2/2',
          name: 'B',
          distance: '2.0km',
          time: '30分',
          walkSessionId: null,
        ),
      ];
      vm().setRoutes(routes);

      expect(state().routes[0].walkSessionId, 'session-1');
      expect(state().routes[1].walkSessionId, isNull);
    });
  });
}
