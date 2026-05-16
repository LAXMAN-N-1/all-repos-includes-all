import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dealer_user.dart';
import '../services/users_service.dart';

/// Provider for user stats (total, active, pending, inactive)
final userStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(usersServiceProvider);
  return service.getStats();
});

/// Provider for the users list with optional filters
final usersProvider =
    FutureProvider.family<List<DealerUser>, Map<String, dynamic>?>(
        (ref, filters) async {
  final service = ref.watch(usersServiceProvider);
  return service.listUsers(
    search: filters?['search'],
    roleId: filters?['role_id'],
    status: filters?['status'],
  );
});

/// Simple users list (no filters) for backward compatibility
final allUsersProvider = FutureProvider<List<DealerUser>>((ref) async {
  final service = ref.watch(usersServiceProvider);
  return service.listUsers();
});

/// Provider for user detail
final userDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, userId) async {
  final service = ref.watch(usersServiceProvider);
  return service.getUserDetail(userId);
});
