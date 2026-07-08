import 'package:flutter_riverpod/flutter_riverpod.dart';

class WantToGoState {
  const WantToGoState({this.selectedCategory});

  final String? selectedCategory;

  WantToGoState copyWith({Object? selectedCategory = _sentinel}) =>
      WantToGoState(
        selectedCategory: selectedCategory == _sentinel
            ? this.selectedCategory
            : selectedCategory as String?,
      );
}

const _sentinel = Object();

class WantToGoViewModel extends Notifier<WantToGoState> {
  @override
  WantToGoState build() => const WantToGoState();

  void selectCategory(String category) {
    final next = state.selectedCategory == category ? null : category;
    state = state.copyWith(selectedCategory: next);
  }
}

final wantToGoViewModelProvider =
    NotifierProvider<WantToGoViewModel, WantToGoState>(
  WantToGoViewModel.new,
);
