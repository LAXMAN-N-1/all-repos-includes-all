import 'package:freezed_annotation/freezed_annotation.dart';

part 'station_state.freezed.dart';
part 'station_state.g.dart';

// ── Station DTO ─────────────────────────────────────────────
@freezed
abstract class StationDto with _$StationDto {
  const factory StationDto({
    required int id,
    required String name,
    required String address,
    @Default('') String city,
    required String status,
    required int totalSlots,
    required String createdAt,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    @Default('automated') String stationType,
    @Default(0) int availableBatteries,
    @Default(0) int availableSlots,
    @Default(false) bool is24x7,
    @Default(0.0) double rating,
    @Default(0) int activeSwaps,
    @Default(0.0) double utilizationPercent,
    @Default(0) int ongoingRentals,
    @Default(0) int chargingBatteries,
    @Default(0) int faultyBatteries,
    @Default(0.0) double todayRevenue,
    @Default(0) int totalReviews,
    @Default(0) int maxCapacity,
    @Default(20.0) double lowStockThreshold,
    String? contactPhone,
    String? contactEmail,
    String? contactName,
    String? operatingHours,
    String? lastMaintenanceDate,
    String? lastHeartbeat,
    String? description,
    String? stationCode,
    String? automationMode,
    String? imageUrl,
    String? approvalStatus,
    String? state,
    String? pinCode,
  }) = _StationDto;

  factory StationDto.fromJson(Map<String, dynamic> json) =>
      _$StationDtoFromJson(json);
}

// ── Station List State ──────────────────────────────────────
@freezed
abstract class StationState with _$StationState {
  const factory StationState({
    @Default(true) bool isLoading,
    String? error,
    @Default([]) List<StationDto> stations,
  }) = _StationState;
}

// ── Dealer Quick Stats ──────────────────────────────────────
@freezed
abstract class DealerStatsDto with _$DealerStatsDto {
  const factory DealerStatsDto({
    @Default(0) int availableBatteries,
    @Default(0) int totalBatteries,
    @Default(0) int ongoingRentals,
    @Default(0) int currentSwaps,
    @Default(0.0) double avgRating,
    @Default(0) int stationCount,
  }) = _DealerStatsDto;

  factory DealerStatsDto.fromJson(Map<String, dynamic> json) =>
      _$DealerStatsDtoFromJson(json);
}

// ── Battery DTO ─────────────────────────────────────────────
@freezed
abstract class BatteryDto with _$BatteryDto {
  const factory BatteryDto({
    required int id,
    required String serialNumber,
    @Default('') String stationName,
    @Default(0) int stationId,
    @Default('available') String status,
    @Default(100.0) double chargePercentage,
    @Default(100.0) double healthPercentage,
    @Default(0) int cycleCount,
    @Default('') String batteryType,
    String? currentCustomer,
    String? rentalStartTime,
    String? lastRental,
    @Default(0) int daysIdle,
    String? faultDescription,
    String? lastChargedAt,
    String? createdAt,
  }) = _BatteryDto;

  factory BatteryDto.fromJson(Map<String, dynamic> json) =>
      _$BatteryDtoFromJson(json);
}

// ── Active Rental DTO ───────────────────────────────────────
@freezed
abstract class ActiveRentalDto with _$ActiveRentalDto {
  const factory ActiveRentalDto({
    required int id,
    @Default('') String customerName,
    @Default('') String customerPhone,
    @Default('') String customerInitial,
    @Default('') String batteryCode,
    @Default(0) int batteryId,
    @Default('') String stationName,
    @Default(0) int stationId,
    required String startTime,
    @Default('') String expectedReturn,
    @Default(0.0) double totalAmount,
    @Default(0.0) double lateFee,
    @Default('active') String status,
    @Default(0) int durationMinutes,
  }) = _ActiveRentalDto;

  factory ActiveRentalDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveRentalDtoFromJson(json);
}

// ── Swap Port DTO ───────────────────────────────────────────
@freezed
abstract class SwapPortDto with _$SwapPortDto {
  const factory SwapPortDto({
    required int portNumber,
    @Default('ready') String state, // ready, active, charging, fault, offline, reserved
    String? customerName,
    String? customerId,
    String? batteryCode,
    String? newBatteryCode,
    @Default(0.0) double chargePercent,
    @Default(100.0) double healthPercentage,
    String? swapStartedAt,
    String? faultCode,
    String? lastUsedAt,
    String? reservationExpiry,
  }) = _SwapPortDto;

  factory SwapPortDto.fromJson(Map<String, dynamic> json) =>
      _$SwapPortDtoFromJson(json);
}

// ── Station Swap Data (combines station + its ports) ────────
@freezed
abstract class StationSwapDataDto with _$StationSwapDataDto {
  const factory StationSwapDataDto({
    required int stationId,
    required String stationName,
    @Default([]) List<SwapPortDto> ports,
    @Default(0) int totalPorts,
    @Default(0) int activeSwaps,
    @Default(0) int availablePorts,
  }) = _StationSwapDataDto;

  factory StationSwapDataDto.fromJson(Map<String, dynamic> json) =>
      _$StationSwapDataDtoFromJson(json);
}

// ── Review DTO ──────────────────────────────────────────────
@freezed
abstract class ReviewDto with _$ReviewDto {
  const factory ReviewDto({
    required int id,
    @Default('') String customerName,
    @Default('') String customerInitial,
    @Default(5) int rating,
    String? reviewText,
    @Default('') String stationName,
    @Default(0) int stationId,
    required String createdAt,
    String? dealerReply,
    String? repliedAt,
    @Default(false) bool isVerifiedRental,
  }) = _ReviewDto;

  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);
}

// ── Swap Event (for ticker) ─────────────────────────────────
@freezed
abstract class SwapEventDto with _$SwapEventDto {
  const factory SwapEventDto({
    required String description,
    required String timestamp,
    @Default('') String batteryCode,
    @Default('') String stationName,
    @Default('completed') String eventType,
  }) = _SwapEventDto;

  factory SwapEventDto.fromJson(Map<String, dynamic> json) =>
      _$SwapEventDtoFromJson(json);
}

// ── Activity Feed Event ─────────────────────────────────────
@freezed
abstract class ActivityEventDto with _$ActivityEventDto {
  const factory ActivityEventDto({
    required int id,
    required String eventType,
    required String description,
    required String createdAt,
    String? batteryCode,
    String? customerName,
    @Default(0.0) double amount,
  }) = _ActivityEventDto;

  factory ActivityEventDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityEventDtoFromJson(json);
}

// ── Transaction DTO ─────────────────────────────────────────
@freezed
abstract class TransactionDto with _$TransactionDto {
  const factory TransactionDto({
    required int id,
    @Default('Rental') String type,
    @Default('') String customer,
    @Default(0.0) double amount,
    required String time,
  }) = _TransactionDto;

  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);
}

// ── Swap DTO (real DB swap sessions) ──────────────────────────
@freezed
abstract class SwapDto with _$SwapDto {
  const factory SwapDto({
    required int id,
    @Default('') String customerName,
    @Default(0) int customerId,
    @Default('') String stationName,
    @Default(0) int stationId,
    @Default('') String oldBatteryCode,
    @Default('') String newBatteryCode,
    @Default(0.0) double oldBatterySoc,
    @Default(0.0) double newBatterySoc,
    @Default(0.0) double swapAmount,
    @Default('completed') String status,
    @Default('paid') String paymentStatus,
    required String createdAt,
    String? completedAt,
  }) = _SwapDto;

  factory SwapDto.fromJson(Map<String, dynamic> json) =>
      _$SwapDtoFromJson(json);
}
