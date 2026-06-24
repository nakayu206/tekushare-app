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
  });
}
