import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/domain/entities/app_update.dart';

void main() {
  Map<String, dynamic> config() => {
        'latestBuild': 15,
        'minimumBuild': 14,
        'version': '1.0.2',
        'storeUrl':
            'https://play.google.com/store/apps/details?id=com.tekushare.app',
      };

  test('必須更新・通常更新・更新不要の境界をビルド番号で判定する', () {
    final update = AppUpdate.fromMap(config())!;
    expect(update.isRequired(13), true);
    expect(update.isRequired(14), false);
    expect(update.isAvailable(14), true);
    expect(update.isAvailable(15), false);
    expect(update.isAvailable(16), false);
  });

  test('不正なビルド設定やストア以外のURLを拒否する', () {
    expect(AppUpdate.fromMap({...config(), 'minimumBuild': 16}), isNull);
    expect(AppUpdate.fromMap({...config(), 'latestBuild': '15'}), isNull);
    expect(
        AppUpdate.fromMap(
            {...config(), 'storeUrl': 'https://evil.example/update'}),
        isNull);
    expect(
        AppUpdate.fromMap({...config(), 'storeUrl': 'http://play.google.com/'}),
        isNull);
  });
}
