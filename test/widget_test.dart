// アプリ起動の基本テスト
import 'package:flutter_test/flutter_test.dart';

import 'package:tekushare/app.dart';
import 'package:tekushare/core/config/flavor.dart';

void main() {
  testWidgets('アプリが起動する', (WidgetTester tester) async {
    AppConfig.setFlavor(Flavor.dev);
    await tester.pumpWidget(const TekuShareApp());
    expect(find.textContaining('TekuShare'), findsWidgets);
  });
}
