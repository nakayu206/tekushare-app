import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_strings.dart';

class SpotDetailState {
  const SpotDetailState({
    this.selectedCategory = AppStrings.categoryPark,
  });

  final String selectedCategory;

  SpotDetailState copyWith({String? selectedCategory}) => SpotDetailState(
        selectedCategory: selectedCategory ?? this.selectedCategory,
      );
}

class SpotDetailViewModel extends Notifier<SpotDetailState> {
  @override
  SpotDetailState build() => const SpotDetailState();

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final spotDetailViewModelProvider =
    NotifierProvider<SpotDetailViewModel, SpotDetailState>(
  SpotDetailViewModel.new,
);
