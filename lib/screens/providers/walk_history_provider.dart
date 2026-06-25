import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/walk_session.dart';
import 'package:tekushare/domain/usecases/walk/get_walk_history.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

final walkHistoryProvider = FutureProvider<List<WalkSession>>((ref) {
  return GetWalkHistory(ref.watch(walkSessionRepositoryProvider)).call();
});
