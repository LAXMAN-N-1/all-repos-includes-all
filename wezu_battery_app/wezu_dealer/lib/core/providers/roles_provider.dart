import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_response.dart';
import '../models/dealer_role.dart';

final rolesProvider = FutureProvider<List<DealerRole>>((ref) async {
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get(ApiConstants.roles);

    if (response.statusCode == 200) {
      final List data = ApiResponse.asList(response.data, keys: const ['roles']);
      return data.map((json) => DealerRole.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load roles');
    }
  } catch (e) {
    throw Exception('Error fetching roles: $e');
  }
});
