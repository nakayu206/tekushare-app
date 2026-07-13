import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tekushare/app.dart';
import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/providers/auth_provider.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

/// Firebase を初期化せずに使えるフェイク User。
/// app.dart が参照するのは displayName のみ。
class _FakeUser implements User {
  @override
  String? get displayName => 'テストユーザー';

  @override
  String get uid => '';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthService implements AuthService {
  @override
  Stream<User?> watchAuthState() => const Stream.empty();
  @override
  Future<void> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {}
  @override
  Future<void> signInWithEmail(String email, String password) async {}
  @override
  Future<void> setDisplayName(String name) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> deleteUser() async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppConfig.setFlavor(Flavor.dev);
  });

  Future<void> launchApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(_FakeAuthService()),
          // ログイン済みユーザーを即時提供し Firebase アクセスを回避
          authStateProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        ],
        child: const TekuShareApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('app launch flow', () {
    testWidgets('launches app and shows home screen', (tester) async {
      await launchApp(tester);

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    testWidgets('navigates to list tab via bottom nav', (tester) async {
      await launchApp(tester);

      await tester.tap(find.text(AppStrings.navList));
      await tester.pumpAndSettle();

      expect(find.byType(SpotListPage), findsOneWidget);
    });
  });
}
