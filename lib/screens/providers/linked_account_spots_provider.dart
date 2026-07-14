import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/spot.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

class LinkedAccountSpots {
  const LinkedAccountSpots({
    required this.wantToGoSpots,
    required this.visitedSpots,
  });

  final List<Spot> wantToGoSpots;
  final List<Spot> visitedSpots;
}

final linkedAccountSpotsProvider =
    FutureProvider.family<LinkedAccountSpots, String>((ref, otherUid) async {
  final repo = ref.watch(accountLinkRepositoryProvider);
  final settings = await repo.fetchShareSettings(otherUid);

  if (!settings.shareWantToGo && !settings.shareVisited) {
    return const LinkedAccountSpots(wantToGoSpots: [], visitedSpots: []);
  }

  final spots = await repo.fetchSharedSpots(
    otherUid,
    shareWantToGo: settings.shareWantToGo,
    shareVisited: settings.shareVisited,
  );
  return LinkedAccountSpots(
    wantToGoSpots: spots.where((s) => s.status == SpotStatus.wantToGo).toList(),
    visitedSpots: spots.where((s) => s.status == SpotStatus.visited).toList(),
  );
});
