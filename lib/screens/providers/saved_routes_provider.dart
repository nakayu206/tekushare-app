import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/saved_route.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

final savedRoutesProvider = FutureProvider<List<SavedRoute>>((ref) async {
  final repo = ref.watch(savedRouteRepositoryProvider);
  return repo.getAll();
});
