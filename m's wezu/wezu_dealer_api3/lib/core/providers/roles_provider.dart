import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_response.dart';
import '../models/dealer_role.dart';

final rolesProvider = FutureProvider<List<DealerRole>>((ref) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get(ApiConstants.roles);
    // Backend may return one of several shapes:
    //   [...]                              — plain list
    //   {"data": [...]}                    — wrapped list
    //   {"roles": [...]}                   — keyed list
    //   {"data": {"roles": [...]}}         — nested keyed list
    final rawList = ApiResponse.asList(
      response.data,
      keys: const ['roles', 'data'],
    );
    return rawList
        .whereType<Map>()
        .map((json) => DealerRole.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  } on DioException catch (e) {
    // Surface the real backend error message instead of wrapping it
    throw Exception(ApiResponse.errorMessage(e, fallback: 'Failed to load roles'));
  } catch (e) {
    throw Exception('Failed to load roles: $e');
  }
});
