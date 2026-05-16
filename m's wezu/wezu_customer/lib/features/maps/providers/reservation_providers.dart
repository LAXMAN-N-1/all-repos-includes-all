import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reservation.dart';
import '../repositories/reservation_repository.dart';
import '../../../core/network/dio_provider.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return ReservationRepositoryImpl(dio);
});

class ReservationState {
  final Reservation? activeReservation;
  final bool isLoading;
  final String? error;
  final Duration remainingTime;

  ReservationState({
    this.activeReservation,
    this.isLoading = false,
    this.error,
    this.remainingTime = Duration.zero,
  });

  ReservationState copyWith({
    Reservation? activeReservation,
    bool? isLoading,
    String? error,
    Duration? remainingTime,
    bool clearReservation = false,
  }) {
    return ReservationState(
      activeReservation: clearReservation
          ? null
          : (activeReservation ?? this.activeReservation),
      isLoading: isLoading ?? this.isLoading,
      error: error, // Error is cleared unless explicitly provided
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}

class ReservationNotifier extends StateNotifier<ReservationState> {
  final ReservationRepository _repository;
  Timer? _countdownTimer;

  ReservationNotifier(this._repository) : super(ReservationState()) {
    checkActiveReservation();
  }

  Future<void> checkActiveReservation() async {
    state = state.copyWith(isLoading: true);
    try {
      final reservation = await _repository.getActiveReservation();
      if (reservation != null &&
          reservation.status == ReservationStatus.active) {
        state =
            state.copyWith(activeReservation: reservation, isLoading: false);
        _startTimer();
      } else {
        state = state.copyWith(isLoading: false, clearReservation: true);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    if (state.activeReservation == null) return;

    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    final reservation = state.activeReservation;
    if (reservation == null) {
      _countdownTimer?.cancel();
      return;
    }

    final remaining = reservation.expiryTime.difference(DateTime.now());
    if (remaining.isNegative) {
      _countdownTimer?.cancel();
      state =
          state.copyWith(remainingTime: Duration.zero, clearReservation: true);
      // Optional: Show notification or alert about expiry
    } else {
      state = state.copyWith(remainingTime: remaining);
    }
  }

  Future<void> reserveBattery(int stationId, String batteryType) async {
    state = state.copyWith(isLoading: true);
    try {
      final reservation = await _repository.reserveBattery(
        stationId: stationId,
        batteryType: batteryType,
      );
      state = state.copyWith(activeReservation: reservation, isLoading: false);
      _startTimer();
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          error: "Reservation failed: Check balance or existing reservation");
    }
  }

  Future<void> cancelReservation() async {
    final reservationId = state.activeReservation?.id;
    if (reservationId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _repository.cancelReservation(reservationId);
      _countdownTimer?.cancel();
      state = state.copyWith(
          isLoading: false,
          clearReservation: true,
          remainingTime: Duration.zero);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Cancellation failed");
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  return ReservationNotifier(repository);
});
