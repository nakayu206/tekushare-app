import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/config/flavor.dart';

void main() {
  group('AppConfig', () {
    tearDown(() => AppConfig.setFlavor(Flavor.dev));

    test('デフォルトのflavorはdev', () {
      expect(AppConfig.flavor, Flavor.dev);
      expect(AppConfig.appName, 'TekuShare Dev');
      expect(AppConfig.isDev, isTrue);
      expect(AppConfig.isStg, isFalse);
      expect(AppConfig.isProd, isFalse);
    });

    test('stg環境に切り替えるとflavorとappNameが変わる', () {
      AppConfig.setFlavor(Flavor.stg);
      expect(AppConfig.flavor, Flavor.stg);
      expect(AppConfig.appName, 'TekuShare Stg');
      expect(AppConfig.isDev, isFalse);
      expect(AppConfig.isStg, isTrue);
      expect(AppConfig.isProd, isFalse);
    });

    test('prod環境に切り替えるとflavorとappNameが変わる', () {
      AppConfig.setFlavor(Flavor.prod);
      expect(AppConfig.flavor, Flavor.prod);
      expect(AppConfig.appName, 'TekuShare');
      expect(AppConfig.isDev, isFalse);
      expect(AppConfig.isStg, isFalse);
      expect(AppConfig.isProd, isTrue);
    });
  });
}
