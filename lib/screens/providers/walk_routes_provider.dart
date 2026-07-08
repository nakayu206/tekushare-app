import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tekushare/domain/entities/walk_route.dart';
import 'package:tekushare/screens/providers/app_providers.dart';

final walkRoutesProvider = FutureProvider<List<WalkRoute>>((ref) async {
  return ref.watch(routeRepositoryProvider).getAllRoutes();
});
