import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import 'package:dio/dio.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(apiClientProvider).dio;
});
