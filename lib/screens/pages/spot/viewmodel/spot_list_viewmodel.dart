import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/core/constants/app_strings.dart';

typedef SpotItem = ({String date, String title});

class SpotListState {
  const SpotListState({
    this.isWantToGoTab = true,
    this.selectedCategory = AppStrings.categoryPark,
  });

  final bool isWantToGoTab;
  final String selectedCategory;

  static const wantToGoItems = <SpotItem>[
    (date: '4/12', title: 'ひだまりパーク'),
    (date: '5/12', title: 'Cafe&Gallery'),
    (date: '6/12', title: 'カフェ Noce'),
    (date: '7/12', title: 'むすび屋（雑貨屋）'),
    (date: '8/12', title: 'ごはん処 まるふく'),
    (date: '9/12', title: 'cafe hanahana'),
    (date: '10/12', title: 'time spot'),
  ];

  static const wentItems = <SpotItem>[
    (date: '1/15', title: '新宿御苑'),
    (date: '2/03', title: 'タリーズ 銀座店'),
    (date: '3/20', title: 'ブルーボトルコーヒー'),
  ];

  List<SpotItem> get currentItems => isWantToGoTab ? wantToGoItems : wentItems;

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
