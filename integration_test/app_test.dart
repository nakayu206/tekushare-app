import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tekushare/app.dart';
import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/screens/pages/home/view/home_page.dart';
import 'package:tekushare/screens/pages/spot/view/spot_list_page.dart';
import 'package:tekushare/screens/widgets/common/app_bottom_nav.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppConfig.setFlavor(Flavor.dev);
  });

  Future<void> launchApp(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TekuShareApp()),
    );
    await tester.pumpAndSettle();
  }

  group('app launch flow', () {
    // アプリが起動してホーム画面が表示される
    testWidgets('launches app and shows home screen', (tester) async {
      await launchApp(tester);

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    // ボトムナビで「リスト」タブに遷移できる
    testWidgets('navigates to list tab via bottom nav', (tester) async {
      await launchApp(tester);

      await tester.tap(find.text(AppStrings.navList));
      await tester.pumpAndSettle();

      expect(find.byType(SpotListPage), findsOneWidget);
    });
  });
}
