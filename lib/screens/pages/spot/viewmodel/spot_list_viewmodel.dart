import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_strings.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/screens/providers/spot_provider.dart';

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
  SpotListState build() {
    ref.read(selectedSpotStatusProvider.notifier).state = SpotStatus.wantToGo;
    return const SpotListState();
  }

  void selectTab(bool isWantToGo) {
    state = state.copyWith(isWantToGoTab: isWantToGo);
    ref.read(selectedSpotStatusProvider.notifier).state =
        isWantToGo ? SpotStatus.wantToGo : SpotStatus.visited;
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final spotListViewModelProvider =
    NotifierProvider<SpotListViewModel, SpotListState>(
  SpotListViewModel.new,
);
