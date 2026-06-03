import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tekushare/app.dart';
import 'package:tekushare/core/config/flavor.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/presentation/pages/home/home_page.dart';
import 'package:tekushare/presentation/pages/spot/spot_list_page.dart';
import 'package:tekushare/presentation/widgets/common/app_bottom_nav.dart';

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

  group('アプリ起動フロー', () {
    testWidgets('アプリが起動してホーム画面が表示される', (tester) async {
      await launchApp(tester);

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    testWidgets('ボトムナビで「リスト」タブに遷移できる', (tester) async {
      await launchApp(tester);

      await tester.tap(find.text(AppStrings.navList));
      await tester.pumpAndSettle();

      expect(find.byType(SpotListPage), findsOneWidget);
    });
  });
}
