import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/screens/pages/walk/viewmodel/walk_session_viewmodel.dart';

void main() {
  group('WalkSessionViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    // 初期状態は false（散歩中でない）
    test('initial state is false', () {
      expect(container.read(walkSessionProvider), false);
    });

    // startWalk() で true になる
    test('startWalk sets state to true', () {
      container.read(walkSessionProvider.notifier).startWalk();
      expect(container.read(walkSessionProvider), true);
    });

    // endWalk() で false に戻る
    test('endWalk sets state to false', () {
      container.read(walkSessionProvider.notifier).startWalk();
      container.read(walkSessionProvider.notifier).endWalk();
      expect(container.read(walkSessionProvider), false);
    });
  });
}
