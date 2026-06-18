import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_strings.dart';

class WantToGoState {
  const WantToGoState({
    this.selectedCategory = AppStrings.categoryPark,
  });

  final String selectedCategory;

  WantToGoState copyWith({String? selectedCategory}) => WantToGoState(
        selectedCategory: selectedCategory ?? this.selectedCategory,
      );
}

class WantToGoViewModel extends Notifier<WantToGoState> {
  @override
  WantToGoState build() => const WantToGoState();

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final wantToGoViewModelProvider =
    NotifierProvider<WantToGoViewModel, WantToGoState>(
  WantToGoViewModel.new,
);
