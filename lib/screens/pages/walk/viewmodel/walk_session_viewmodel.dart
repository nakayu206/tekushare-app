import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalkSessionViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  void startWalk() => state = true;
  void endWalk() => state = false;
}

final walkSessionProvider =
    NotifierProvider<WalkSessionViewModel, bool>(WalkSessionViewModel.new);
