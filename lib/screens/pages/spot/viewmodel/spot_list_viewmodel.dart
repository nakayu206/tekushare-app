import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_strings.dart';

class SpotListState {
  const SpotListState({
    this.isWantToGoTab = true,
    this.selectedCategory = AppStrings.categoryPark,
  });

  final bool isWantToGoTab;
  final String selectedCategory;

  SpotListState copyWith({
    bool? isWantToGoTab,
    String? selectedCategory,
  }) =>
      SpotListState(
        isWantToGoTab: isWantToGoTab ?? this.isWantToGoTab,
        selectedCategory: selectedCategory ?? this.selectedCategory,
      );
}

class SpotListViewModel extends Notifier<SpotListState> {
  @override
  SpotListState build() => const SpotListState();

  void selectTab(bool isWantToGo) {
    state = state.copyWith(isWantToGoTab: isWantToGo);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final spotListViewModelProvider =
    NotifierProvider<SpotListViewModel, SpotListState>(
  SpotListViewModel.new,
);
