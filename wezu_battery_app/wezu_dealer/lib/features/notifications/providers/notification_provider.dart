import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/notification_state.dart';

final notificationsProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.watch(dioProvider));
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Dio _dio;
  NotificationNotifier(this._dio) : super(const NotificationState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.notifications);
      final rawData = ApiResponse.asMap(response.data);
      final rawList = ApiResponse.asList(rawData, keys: const ['notifications']);
      final parsed = rawList.map((e) => NotificationDto.fromJson(e)).toList();
      state = state.copyWith(
        isLoading: false,
        notifications: parsed,
        unreadCount: rawData['unread_count'] ?? 0,
        total: rawData['total'] ?? 0,
      );
    } on DioException catch (e) {
      log('Notifications API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load notifications'),
      );
    } catch (e) {
      log('Notifications Error: $e');
      state = state.copyWith(isLoading: false, error: 'Unexpected error');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.patch('${ApiConstants.notifications}/$id/read');
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          if (n.id == id) return n.copyWith(isRead: true);
          return n;
        }).toList(),
        unreadCount: (state.unreadCount - 1).clamp(0, 999),
      );
    } catch (e) {
      log('Mark read error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('${ApiConstants.notifications}/read-all');
      state = state.copyWith(
        notifications: state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
        unreadCount: 0,
      );
    } catch (e) {
      log('Mark all read error: $e');
    }
  }
}
