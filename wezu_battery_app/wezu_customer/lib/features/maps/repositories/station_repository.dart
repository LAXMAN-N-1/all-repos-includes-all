import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/station.dart';
import '../../../core/constants/api_constants.dart';

abstract class StationRepository {
  Future<List<Station>> getNearbyStations(double latitude, double longitude,
      {double radius = 50.0});
  Future<Station> getStationDetails(int id);
  Future<List<Station>> searchStations(String query);
}

class StationRepositoryImpl implements StationRepository {
  final Dio _dio;

  StationRepositoryImpl(this._dio);

  @override
  Future<List<Station>> getNearbyStations(double latitude, double longitude,
      {double radius = 50.0}) async {
    try {
      final response = await _dio.get(
        ApiConstants.stationsNearby,
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'radius': radius,
        },
      );

      if (response.data is Map && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((json) => Station.fromJson(json)).toList();
        }
      } else if (response.data is List) {
        return (response.data as List).map((json) => Station.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? (e.response?.data['detail'] ?? e.message)
          : e.message;
      debugPrint('Error fetching nearby stations: $detail');
      throw Exception(detail ?? 'Failed to fetch nearby stations');
    } catch (e) {
      debugPrint('Error fetching nearby stations: $e');
      rethrow;
    }
  }

  @override
  Future<Station> getStationDetails(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.stations}/$id');
          
      if (response.data is Map && response.data['success'] == true) {
        return Station.fromJson(response.data['data']);
      }
      return Station.fromJson(response.data);
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? (e.response?.data['detail'] ?? e.message)
          : e.message;
      debugPrint('Error fetching station details: $detail');
      throw Exception(detail ?? 'Failed to load station details');
    } catch (e) {
      debugPrint('Error fetching station details: $e');
      rethrow;
    }
  }

  @override
  Future<List<Station>> searchStations(String query) async {
    try {
      final response = await _dio.get(
        ApiConstants.stations,
        queryParameters: {'query': query},
      );
      
      if (response.data is Map && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((json) => Station.fromJson(json)).toList();
        }
      } else if (response.data is List) {
        return (response.data as List).map((json) => Station.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? (e.response?.data['detail'] ?? e.message)
          : e.message;
      debugPrint('Error searching stations: $detail');
      throw Exception(detail ?? 'Failed to search stations');
    } catch (e) {
      debugPrint('Error searching stations: $e');
      rethrow;
    }
  }

}
