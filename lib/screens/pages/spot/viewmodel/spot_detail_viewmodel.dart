import 'package:flutter_riverpod/flutter_riverpod.dart';

const _sentinel = Object();

class SpotDetailState {
  const SpotDetailState({this.selectedCategory});

  final String? selectedCategory;

  SpotDetailState copyWith({Object? selectedCategory = _sentinel}) =>
      SpotDetailState(
        selectedCategory: selectedCategory == _sentinel
            ? this.selectedCategory
            : selectedCategory as String?,
      );
}

class SpotDetailViewModel extends Notifier<SpotDetailState> {
  @override
  SpotDetailState build() => const SpotDetailState();

  void initCategory(String? category) {
    state = SpotDetailState(selectedCategory: category);
  }

  void selectCategory(String category) {
    final next = state.selectedCategory == category ? null : category;
    state = state.copyWith(selectedCategory: next);
  }
}

final spotDetailViewModelProvider =
    NotifierProvider<SpotDetailViewModel, SpotDetailState>(
  SpotDetailViewModel.new,
);
