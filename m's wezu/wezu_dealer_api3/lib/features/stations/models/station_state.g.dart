// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StationDto _$StationDtoFromJson(Map<String, dynamic> json) => _StationDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String? ?? '',
      status: json['status'] as String,
      totalSlots: (json['totalSlots'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      stationType: json['stationType'] as String? ?? 'automated',
      availableBatteries: (json['availableBatteries'] as num?)?.toInt() ?? 0,
      availableSlots: (json['availableSlots'] as num?)?.toInt() ?? 0,
      is24x7: json['is24x7'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      activeSwaps: (json['activeSwaps'] as num?)?.toInt() ?? 0,
      utilizationPercent:
          (json['utilizationPercent'] as num?)?.toDouble() ?? 0.0,
      ongoingRentals: (json['ongoingRentals'] as num?)?.toInt() ?? 0,
      chargingBatteries: (json['chargingBatteries'] as num?)?.toInt() ?? 0,
      faultyBatteries: (json['faultyBatteries'] as num?)?.toInt() ?? 0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      maxCapacity: (json['maxCapacity'] as num?)?.toInt() ?? 0,
      lowStockThreshold:
          (json['lowStockThreshold'] as num?)?.toDouble() ?? 20.0,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactName: json['contactName'] as String?,
      operatingHours: json['operatingHours'] as String?,
      lastMaintenanceDate: json['lastMaintenanceDate'] as String?,
      lastHeartbeat: json['lastHeartbeat'] as String?,
      description: json['description'] as String?,
      stationCode: json['stationCode'] as String?,
      automationMode: json['automationMode'] as String?,
      imageUrl: json['imageUrl'] as String?,
      approvalStatus: json['approvalStatus'] as String?,
      state: json['state'] as String?,
      pinCode: json['pinCode'] as String?,
    );

Map<String, dynamic> _$StationDtoToJson(_StationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'status': instance.status,
      'totalSlots': instance.totalSlots,
      'createdAt': instance.createdAt,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'stationType': instance.stationType,
      'availableBatteries': instance.availableBatteries,
      'availableSlots': instance.availableSlots,
      'is24x7': instance.is24x7,
      'rating': instance.rating,
      'activeSwaps': instance.activeSwaps,
      'utilizationPercent': instance.utilizationPercent,
      'ongoingRentals': instance.ongoingRentals,
      'chargingBatteries': instance.chargingBatteries,
      'faultyBatteries': instance.faultyBatteries,
      'todayRevenue': instance.todayRevenue,
      'totalReviews': instance.totalReviews,
      'maxCapacity': instance.maxCapacity,
      'lowStockThreshold': instance.lowStockThreshold,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'contactName': instance.contactName,
      'operatingHours': instance.operatingHours,
      'lastMaintenanceDate': instance.lastMaintenanceDate,
      'lastHeartbeat': instance.lastHeartbeat,
      'description': instance.description,
      'stationCode': instance.stationCode,
      'automationMode': instance.automationMode,
      'imageUrl': instance.imageUrl,
      'approvalStatus': instance.approvalStatus,
      'state': instance.state,
      'pinCode': instance.pinCode,
    };

_DealerStatsDto _$DealerStatsDtoFromJson(Map<String, dynamic> json) =>
    _DealerStatsDto(
      availableBatteries: (json['availableBatteries'] as num?)?.toInt() ?? 0,
      totalBatteries: (json['totalBatteries'] as num?)?.toInt() ?? 0,
      ongoingRentals: (json['ongoingRentals'] as num?)?.toInt() ?? 0,
      currentSwaps: (json['currentSwaps'] as num?)?.toInt() ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      stationCount: (json['stationCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DealerStatsDtoToJson(_DealerStatsDto instance) =>
    <String, dynamic>{
      'availableBatteries': instance.availableBatteries,
      'totalBatteries': instance.totalBatteries,
      'ongoingRentals': instance.ongoingRentals,
      'currentSwaps': instance.currentSwaps,
      'avgRating': instance.avgRating,
      'stationCount': instance.stationCount,
    };

_BatteryDto _$BatteryDtoFromJson(Map<String, dynamic> json) => _BatteryDto(
      id: (json['id'] as num).toInt(),
      serialNumber: json['serialNumber'] as String,
      stationName: json['stationName'] as String? ?? '',
      stationId: (json['stationId'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'available',
      chargePercentage: (json['chargePercentage'] as num?)?.toDouble() ?? 100.0,
      healthPercentage: (json['healthPercentage'] as num?)?.toDouble() ?? 100.0,
      cycleCount: (json['cycleCount'] as num?)?.toInt() ?? 0,
      batteryType: json['batteryType'] as String? ?? '',
      currentCustomer: json['currentCustomer'] as String?,
      rentalStartTime: json['rentalStartTime'] as String?,
      lastRental: json['lastRental'] as String?,
      daysIdle: (json['daysIdle'] as num?)?.toInt() ?? 0,
      faultDescription: json['faultDescription'] as String?,
      lastChargedAt: json['lastChargedAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$BatteryDtoToJson(_BatteryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serialNumber': instance.serialNumber,
      'stationName': instance.stationName,
      'stationId': instance.stationId,
      'status': instance.status,
      'chargePercentage': instance.chargePercentage,
      'healthPercentage': instance.healthPercentage,
      'cycleCount': instance.cycleCount,
      'batteryType': instance.batteryType,
      'currentCustomer': instance.currentCustomer,
      'rentalStartTime': instance.rentalStartTime,
      'lastRental': instance.lastRental,
      'daysIdle': instance.daysIdle,
      'faultDescription': instance.faultDescription,
      'lastChargedAt': instance.lastChargedAt,
      'createdAt': instance.createdAt,
    };

_ActiveRentalDto _$ActiveRentalDtoFromJson(Map<String, dynamic> json) =>
    _ActiveRentalDto(
      id: (json['id'] as num).toInt(),
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      customerInitial: json['customerInitial'] as String? ?? '',
      batteryCode: json['batteryCode'] as String? ?? '',
      batteryId: (json['batteryId'] as num?)?.toInt() ?? 0,
      stationName: json['stationName'] as String? ?? '',
      stationId: (json['stationId'] as num?)?.toInt() ?? 0,
      startTime: json['startTime'] as String,
      expectedReturn: json['expectedReturn'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      lateFee: (json['lateFee'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'active',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ActiveRentalDtoToJson(_ActiveRentalDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'customerInitial': instance.customerInitial,
      'batteryCode': instance.batteryCode,
      'batteryId': instance.batteryId,
      'stationName': instance.stationName,
      'stationId': instance.stationId,
      'startTime': instance.startTime,
      'expectedReturn': instance.expectedReturn,
      'totalAmount': instance.totalAmount,
      'lateFee': instance.lateFee,
      'status': instance.status,
      'durationMinutes': instance.durationMinutes,
    };

_SwapPortDto _$SwapPortDtoFromJson(Map<String, dynamic> json) => _SwapPortDto(
      portNumber: (json['portNumber'] as num).toInt(),
      state: json['state'] as String? ?? 'ready',
      customerName: json['customerName'] as String?,
      customerId: json['customerId'] as String?,
      batteryCode: json['batteryCode'] as String?,
      newBatteryCode: json['newBatteryCode'] as String?,
      chargePercent: (json['chargePercent'] as num?)?.toDouble() ?? 0.0,
      healthPercentage: (json['healthPercentage'] as num?)?.toDouble() ?? 100.0,
      swapStartedAt: json['swapStartedAt'] as String?,
      faultCode: json['faultCode'] as String?,
      lastUsedAt: json['lastUsedAt'] as String?,
      reservationExpiry: json['reservationExpiry'] as String?,
    );

Map<String, dynamic> _$SwapPortDtoToJson(_SwapPortDto instance) =>
    <String, dynamic>{
      'portNumber': instance.portNumber,
      'state': instance.state,
      'customerName': instance.customerName,
      'customerId': instance.customerId,
      'batteryCode': instance.batteryCode,
      'newBatteryCode': instance.newBatteryCode,
      'chargePercent': instance.chargePercent,
      'healthPercentage': instance.healthPercentage,
      'swapStartedAt': instance.swapStartedAt,
      'faultCode': instance.faultCode,
      'lastUsedAt': instance.lastUsedAt,
      'reservationExpiry': instance.reservationExpiry,
    };

_StationSwapDataDto _$StationSwapDataDtoFromJson(Map<String, dynamic> json) =>
    _StationSwapDataDto(
      stationId: (json['stationId'] as num).toInt(),
      stationName: json['stationName'] as String,
      ports: (json['ports'] as List<dynamic>?)
              ?.map((e) => SwapPortDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalPorts: (json['totalPorts'] as num?)?.toInt() ?? 0,
      activeSwaps: (json['activeSwaps'] as num?)?.toInt() ?? 0,
      availablePorts: (json['availablePorts'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StationSwapDataDtoToJson(_StationSwapDataDto instance) =>
    <String, dynamic>{
      'stationId': instance.stationId,
      'stationName': instance.stationName,
      'ports': instance.ports,
      'totalPorts': instance.totalPorts,
      'activeSwaps': instance.activeSwaps,
      'availablePorts': instance.availablePorts,
    };

_ReviewDto _$ReviewDtoFromJson(Map<String, dynamic> json) => _ReviewDto(
      id: (json['id'] as num).toInt(),
      customerName: json['customerName'] as String? ?? '',
      customerInitial: json['customerInitial'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      reviewText: json['reviewText'] as String?,
      stationName: json['stationName'] as String? ?? '',
      stationId: (json['stationId'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String,
      dealerReply: json['dealerReply'] as String?,
      repliedAt: json['repliedAt'] as String?,
      isVerifiedRental: json['isVerifiedRental'] as bool? ?? false,
    );

Map<String, dynamic> _$ReviewDtoToJson(_ReviewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'customerInitial': instance.customerInitial,
      'rating': instance.rating,
      'reviewText': instance.reviewText,
      'stationName': instance.stationName,
      'stationId': instance.stationId,
      'createdAt': instance.createdAt,
      'dealerReply': instance.dealerReply,
      'repliedAt': instance.repliedAt,
      'isVerifiedRental': instance.isVerifiedRental,
    };

_SwapEventDto _$SwapEventDtoFromJson(Map<String, dynamic> json) =>
    _SwapEventDto(
      description: json['description'] as String,
      timestamp: json['timestamp'] as String,
      batteryCode: json['batteryCode'] as String? ?? '',
      stationName: json['stationName'] as String? ?? '',
      eventType: json['eventType'] as String? ?? 'completed',
    );

Map<String, dynamic> _$SwapEventDtoToJson(_SwapEventDto instance) =>
    <String, dynamic>{
      'description': instance.description,
      'timestamp': instance.timestamp,
      'batteryCode': instance.batteryCode,
      'stationName': instance.stationName,
      'eventType': instance.eventType,
    };

_ActivityEventDto _$ActivityEventDtoFromJson(Map<String, dynamic> json) =>
    _ActivityEventDto(
      id: (json['id'] as num).toInt(),
      eventType: json['eventType'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] as String,
      batteryCode: json['batteryCode'] as String?,
      customerName: json['customerName'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$ActivityEventDtoToJson(_ActivityEventDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventType': instance.eventType,
      'description': instance.description,
      'createdAt': instance.createdAt,
      'batteryCode': instance.batteryCode,
      'customerName': instance.customerName,
      'amount': instance.amount,
    };

_TransactionDto _$TransactionDtoFromJson(Map<String, dynamic> json) =>
    _TransactionDto(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String? ?? 'Rental',
      customer: json['customer'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] as String,
    );

Map<String, dynamic> _$TransactionDtoToJson(_TransactionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'customer': instance.customer,
      'amount': instance.amount,
      'time': instance.time,
    };

_SwapDto _$SwapDtoFromJson(Map<String, dynamic> json) => _SwapDto(
      id: (json['id'] as num).toInt(),
      customerName: json['customerName'] as String? ?? '',
      customerId: (json['customerId'] as num?)?.toInt() ?? 0,
      stationName: json['stationName'] as String? ?? '',
      stationId: (json['stationId'] as num?)?.toInt() ?? 0,
      oldBatteryCode: json['oldBatteryCode'] as String? ?? '',
      newBatteryCode: json['newBatteryCode'] as String? ?? '',
      oldBatterySoc: (json['oldBatterySoc'] as num?)?.toDouble() ?? 0.0,
      newBatterySoc: (json['newBatterySoc'] as num?)?.toDouble() ?? 0.0,
      swapAmount: (json['swapAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'completed',
      paymentStatus: json['paymentStatus'] as String? ?? 'paid',
      createdAt: json['createdAt'] as String,
      completedAt: json['completedAt'] as String?,
    );

Map<String, dynamic> _$SwapDtoToJson(_SwapDto instance) => <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'customerId': instance.customerId,
      'stationName': instance.stationName,
      'stationId': instance.stationId,
      'oldBatteryCode': instance.oldBatteryCode,
      'newBatteryCode': instance.newBatteryCode,
      'oldBatterySoc': instance.oldBatterySoc,
      'newBatterySoc': instance.newBatterySoc,
      'swapAmount': instance.swapAmount,
      'status': instance.status,
      'paymentStatus': instance.paymentStatus,
      'createdAt': instance.createdAt,
      'completedAt': instance.completedAt,
    };
