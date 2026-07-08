import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';

const _sentinel = Object();

class SpotListState {
  const SpotListState({
    this.isWantToGoTab = true,
    this.selectedCategory,
  });

  final bool isWantToGoTab;
  final String? selectedCategory;

  SpotListState copyWith({
    bool? isWantToGoTab,
    Object? selectedCategory = _sentinel,
  }) =>
      SpotListState(
        isWantToGoTab: isWantToGoTab ?? this.isWantToGoTab,
        selectedCategory: selectedCategory == _sentinel
            ? this.selectedCategory
            : selectedCategory as String?,
      );
}

class SpotListViewModel extends Notifier<SpotListState> {
  @override
  SpotListState build() => const SpotListState();

  void selectTab(bool isWantToGo) {
    state = state.copyWith(isWantToGoTab: isWantToGo, selectedCategory: null);
    ref.read(selectedSpotStatusProvider.notifier).state =
        isWantToGo ? SpotStatus.wantToGo : SpotStatus.visited;
    ref.read(selectedCategoryProvider.notifier).state = null;
  }

  void selectCategory(String category) {
    final next = state.selectedCategory == category ? null : category;
    state = state.copyWith(selectedCategory: next);
    ref.read(selectedCategoryProvider.notifier).state = next;
  }
}

final spotListViewModelProvider =
    NotifierProvider<SpotListViewModel, SpotListState>(
  SpotListViewModel.new,
);
