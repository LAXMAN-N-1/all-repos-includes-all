import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../core/network/api_client.dart';
import '../models/battery_health.dart';

class BatteryHealthService {
  Stream<BatteryHealth> getHealthTelemetry(String batteryId) async* {
    while (true) {
      try {
        final response =
            await apiClient.get('/telematics/battery/$batteryId/latest');
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final temp = (data['temperature'] as num?)?.toDouble() ?? 0.0;

          TempState state = TempState.normal;
          if (temp > 35) state = TempState.warning;
          if (temp > 42) state = TempState.critical;

          List<int> degradationTrend = [
            (data['soh'] as num?)?.toInt() ?? 100,
          ];
          try {
            final historyResponse = await apiClient
                .get('/batteries/$batteryId/health-history', queryParameters: {
              'limit': 10,
            });
            if (historyResponse.statusCode == 200 &&
                historyResponse.data is Map &&
                historyResponse.data['data'] is List) {
              final List<dynamic> historyData =
                  historyResponse.data['data'] as List<dynamic>;
              if (historyData.isNotEmpty) {
                degradationTrend = historyData
                    .map((d) =>
                        (d['health_percentage'] as num?)?.toInt() ??
                        (d['soh'] as num?)?.toInt() ??
                        100)
                    .toList();
              }
            }
          } catch (e) {
            debugPrint('Error fetching battery health history: $e');
          }

          yield BatteryHealth(
            voltage: (data['voltage'] as num?)?.toDouble() ?? 0.0,
            minVoltage: 48.0,
            maxVoltage: 54.6,
            temperature: temp,
            tempState: state,
            soc: (data['soc'] as num?)?.toInt() ?? 0,
            soh: (data['soh'] as num?)?.toInt() ?? 0,
            degradationTrend: degradationTrend,
          );
        }
      } catch (e) {
        debugPrint('Error fetching battery health: $e');
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }
}
