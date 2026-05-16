import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../rental/providers/rental_providers.dart';

/// Model for wallet balance from GET /wallet/balance
class WalletBalance {
  final double balance;
  final double cashbackBalance;
  final String currency;

  WalletBalance({
    required this.balance,
    required this.cashbackBalance,
    required this.currency,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      cashbackBalance: (json['cashback_balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}

/// Model for aggregated dashboard stats from GET /customer/dashboard/stats
class DashboardStats {
  final int activeRentals;
  final int totalRentals;
  final double walletBalance;
  final int rewardPoints;
  final double carbonSavedKg;

  DashboardStats({
    required this.activeRentals,
    required this.totalRentals,
    required this.walletBalance,
    required this.rewardPoints,
    required this.carbonSavedKg,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activeRentals: json['active_rentals'] as int? ?? 0,
      totalRentals: json['total_rentals'] as int? ?? 0,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      rewardPoints: json['reward_points'] as int? ?? 0,
      carbonSavedKg: (json['carbon_saved_kg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Fetches wallet balance from GET /wallet/balance
final walletBalanceProvider = FutureProvider<WalletBalance>((ref) async {
  final dio = ref.watch(authenticatedDioProvider);
  final response = await dio.get('/wallet/balance');
  return WalletBalance.fromJson(response.data as Map<String, dynamic>);
});

/// Fetches aggregated dashboard stats from GET /customer/dashboard/stats
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final dio = ref.watch(authenticatedDioProvider);
  final response = await dio.get('/customer/dashboard/stats');
  return DashboardStats.fromJson(response.data as Map<String, dynamic>);
});

/// Computed provider: active rental count from the active rentals list
final activeRentalCountProvider = FutureProvider<int>((ref) async {
  final rentals = await ref.watch(activeRentalsProvider.future);
  return rentals.length;
});

/// Computed provider: total rental count from rental history
final totalRentalCountProvider = FutureProvider<int>((ref) async {
  final history = await ref.watch(rentalHistoryProvider.future);
  return history.length;
});
