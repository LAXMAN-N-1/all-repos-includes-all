import 'dart:developer';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/document_state.dart';

final documentsProvider =
    StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
  return DocumentNotifier(ref.watch(dioProvider));
});

class DocumentNotifier extends StateNotifier<DocumentState> {
  final Dio _dio;
  DocumentNotifier(this._dio) : super(const DocumentState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.documents);

      // Backend returns {"data": [...], "total": N}
      final dynamic responseData = response.data;
      List rawList = [];
      if (responseData is List) {
        rawList = responseData;
      } else if (responseData is Map) {
        rawList = responseData['data'] ??
            responseData['documents'] ??
            responseData['items'] ??
            [];
      }

      final parsed = rawList.map((e) {
        // Handle SQLModel serialization — may serialize differently
        final Map<String, dynamic> item = e is Map<String, dynamic> ? e : {};
        return DocumentDto(
          id: item['id'] ?? 0,
          documentType: item['document_type']?.toString() ?? 'other',
          status: item['status']?.toString() ?? 'PENDING',
          category: item['category']?.toString(),
          fileUrl: item['file_url']?.toString() ?? '',
          version: item['version'] ?? 1,
          validUntil: item['valid_until']?.toString(),
        );
      }).toList();
      state = state.copyWith(isLoading: false, documents: parsed);
    } on DioException catch (e) {
      log('Documents API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['detail'] ?? 'Failed to load documents',
      );
    } catch (e) {
      log('Documents Error: $e');
      state = state.copyWith(isLoading: false, error: 'Unexpected error');
    }
  }

  /// Upload raw file bytes to the server; returns the stored file URL or null on error.
  Future<String?> uploadFileBytes(Uint8List bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });
      final response =
          await _dio.post(ApiConstants.documentFileUpload, data: formData);
      final body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      return body['file_url']?.toString() ?? body['url']?.toString();
    } catch (e) {
      log('File upload error: $e');
      return null;
    }
  }

  Future<bool> uploadDocument({
    required String documentType,
    required String fileUrl,
    String category = 'verification',
    String? validUntil,
  }) async {
    try {
      await _dio.post(ApiConstants.documentUpload, data: {
        'document_type': documentType,
        'file_url': fileUrl,
        'category': category,
        if (validUntil != null) 'valid_until': validUntil,
      });
      await refresh();
      return true;
    } catch (e) {
      log('Document upload error: $e');
      return false;
    }
  }
}
