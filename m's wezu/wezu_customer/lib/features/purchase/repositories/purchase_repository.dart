import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/battery_product.dart';

class BatteryPurchaseRepository {
  final Dio _dio;
  BatteryPurchaseRepository(this._dio);

  Future<List<BatteryProduct>> searchProducts({
    String? query,
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/catalog/products',
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
          if (category != null && category != 'All') 'category': category,
          if (brand != null && brand != 'All') 'brand': brand,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
          if (sortBy != null) 'sort_by': sortBy,
          'page': page,
          'page_size': pageSize,
        },
      );

      // Backend returns items directly in data or inside a dict
      final dynamic responseData = response.data;
      List<dynamic> items = [];
      if (responseData is Map) {
        if (responseData.containsKey('data') &&
            responseData['data'] is Map &&
            responseData['data'].containsKey('items')) {
          items = responseData['data']['items'];
        } else if (responseData.containsKey('items')) {
          items = responseData['items'];
        }
      } else if (responseData is List) {
        items = responseData;
      }

      return items.map((json) => BatteryProduct.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getMetadata() async {
    try {
      final response = await _dio.get('/catalog/products/metadata');
      final payload = response.data;
      if (payload is Map<String, dynamic> &&
          payload['data'] is Map<String, dynamic>) {
        return payload['data'] as Map<String, dynamic>;
      }
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching catalog metadata: $e');
      return {};
    }
  }

  Future<BatteryProduct?> getProductDetails(String id) async {
    try {
      final response = await _dio.get('/catalog/products/$id');
      final payload = response.data;
      if (payload is Map<String, dynamic> &&
          payload['data'] is Map<String, dynamic>) {
        return BatteryProduct.fromJson(payload['data'] as Map<String, dynamic>);
      }
      if (payload is Map<String, dynamic>) {
        return BatteryProduct.fromJson(payload);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, String> shippingAddress,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      final response = await _dio.post(
        '/catalog/orders',
        data: {
          'items': items,
          'shipping_address': shippingAddress,
          'payment_method': paymentMethod,
          if (promoCode != null) 'promo_code': promoCode,
        },
      );
      return response.data['data'];
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  // --- Cart Persistence ---

  Future<List<dynamic>> getCart() async {
    try {
      final response = await _dio.get('/catalog/cart');
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      debugPrint('Error getting cart: $e');
      return [];
    }
  }

  Future<bool> addToCart(int productId,
      {int? variantId, int quantity = 1}) async {
    try {
      await _dio.post(
        '/catalog/cart',
        data: {
          'product_id': productId,
          if (variantId != null) 'variant_id': variantId,
          'quantity': quantity,
        },
      );
      return true;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return false;
    }
  }

  Future<bool> updateCartQuantity(int itemId, int quantity) async {
    try {
      await _dio.patch(
        '/catalog/cart/$itemId',
        data: {'quantity': quantity},
      );
      return true;
    } catch (e) {
      debugPrint('Error updating cart: $e');
      return false;
    }
  }

  Future<bool> removeFromCart(int itemId) async {
    try {
      await _dio.delete('/catalog/cart/$itemId');
      return true;
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> checkoutFromCart({
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post(
        '/catalog/orders/checkout',
        data: {
          'shipping_address': shippingAddress,
          'payment_method': paymentMethod,
        },
      );
      return response.data['data'];
    } catch (e) {
      debugPrint('Error checking out: $e');
      return null;
    }
  }
}
