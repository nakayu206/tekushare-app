import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/screens/pages/spot/viewmodel/spot_detail_viewmodel.dart';

void main() {
  group('SpotDetailViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    SpotDetailState state() => container.read(spotDetailViewModelProvider);
    SpotDetailViewModel vm() =>
        container.read(spotDetailViewModelProvider.notifier);

    // 初期カテゴリは未選択（null）
    test('initial selectedCategory is park', () {
      expect(state().selectedCategory, isNull);
    });

    // selectCategory でカテゴリが更新される
    test('selectCategory updates selectedCategory', () {
      vm().selectCategory(AppStrings.categoryCafe);
      expect(state().selectedCategory, AppStrings.categoryCafe);
    });

    // copyWith で値を渡さないと元の値が保持される
    test('copyWith without args preserves existing values', () {
      vm().selectCategory(AppStrings.categoryCafe);
      final copy = state().copyWith();
      expect(copy.selectedCategory, AppStrings.categoryCafe);
    });
  });
}
