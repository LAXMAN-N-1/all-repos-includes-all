import 'package:dio/dio.dart';
import '../models/battery.dart';
import '../../../core/constants/api_constants.dart';

abstract class BatteryRepository {
  Future<List<Battery>> getBatteriesAtStation(int stationId);
  Future<Battery> scanQr(String qrData);
  Future<Battery> getBatteryDetails(int id);
}

class BatteryRepositoryImpl implements BatteryRepository {
  final Dio _dio;

  BatteryRepositoryImpl(this._dio);

  @override
  Future<List<Battery>> getBatteriesAtStation(int stationId) async {
    final response = await _dio.get('${ApiConstants.stations}/$stationId/batteries')
        .timeout(const Duration(seconds: 10));
        
    if (response.data is List) {
      return (response.data as List).map((json) => Battery.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<Battery> scanQr(String qrData) async {
    try {
      final response = await _dio.post(
        ApiConstants.scanQr,
        data: {'qr_data': qrData},
      );
      return Battery.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Battery> getBatteryDetails(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.batteries}/$id');
      return Battery.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
