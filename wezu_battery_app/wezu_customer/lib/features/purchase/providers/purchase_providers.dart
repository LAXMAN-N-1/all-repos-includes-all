import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../repositories/purchase_repository.dart';
import '../models/battery_product.dart';
import '../../rental/models/battery.dart'; // For BatteryVariant if it's there, or check model

// Repository provider
final batteryPurchaseRepositoryProvider = Provider<BatteryPurchaseRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return BatteryPurchaseRepository(dio);
});

// Search query provider
final batterySearchQueryProvider = StateProvider<String>((ref) => '');

// Filters provider
final batteryFiltersProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'category': 'All',
    'brand': 'All',
    'min_price': null,
    'max_price': null,
    'sortBy': 'featured',
  };
});

// Products provider
final batteryProductsProvider = FutureProvider<List<BatteryProduct>>((ref) async {
  final query = ref.watch(batterySearchQueryProvider);
  final filters = ref.watch(batteryFiltersProvider);
  final repository = ref.watch(batteryPurchaseRepositoryProvider);
  
  return repository.searchProducts(
    query: query,
    category: filters['category'],
    brand: filters['brand'],
    minPrice: filters['min_price'],
    maxPrice: filters['max_price'],
    sortBy: filters['sortBy'],
  );
});

// Product details provider
final batteryDetailsProvider = FutureProvider.family<BatteryProduct?, String>((ref, id) async {
  final repository = ref.watch(batteryPurchaseRepositoryProvider);
  return repository.getProductDetails(id);
});

// Catalog metadata provider
final batteryCatalogMetadataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(batteryPurchaseRepositoryProvider);
  return repository.getMetadata();
});

// Cart Item Model
class CartItem {
  final int? id; // Backend database ID
  final BatteryProduct product;
  final BatteryVariant? variant;
  final int quantity;

  CartItem({
    this.id,
    required this.product,
    this.variant,
    this.quantity = 1,
  });

  double get totalPrice => (variant?.price ?? product.price) * quantity;

  CartItem copyWith({int? id, int? quantity}) {
    return CartItem(
      id: id ?? this.id,
      product: product,
      variant: variant,
      quantity: quantity ?? this.quantity,
    );
  }
}

// Cart state provider
class CartNotifier extends StateNotifier<List<CartItem>> {
  final BatteryPurchaseRepository _repository;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CartNotifier(this._repository) : super([]) {
    loadCart();
  }

  Future<void> loadCart() async {
    _isLoading = true;
    final List<dynamic> data = await _repository.getCart();
    state = data.map((json) {
      return CartItem(
        id: json['id'],
        product: BatteryProduct.fromJson(json['product']),
        variant: json['variant'] != null ? BatteryVariant.fromJson(json['variant']) : null,
        quantity: json['quantity'],
      );
    }).toList();
    _isLoading = false;
  }

  Future<void> addItem(BatteryProduct product, {BatteryVariant? variant, int quantity = 1}) async {
    final success = await _repository.addToCart(
      int.parse(product.id), 
      variantId: variant != null ? int.parse(variant.id) : null, 
      quantity: quantity
    );
    if (success) {
      await loadCart();
    }
  }

  Future<void> removeItem(int cartItemId) async {
    final success = await _repository.removeFromCart(cartItemId);
    if (success) {
      state = state.where((item) => item.id != cartItemId).toList();
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(cartItemId);
      return;
    }
    final success = await _repository.updateCartQuantity(cartItemId, quantity);
    if (success) {
      state = [
        for (final item in state)
          if (item.id == cartItemId)
            item.copyWith(quantity: quantity)
          else
            item
      ];
    }
  }

  Future<void> clear() async {
    // Backend clear cart could be added to repo
    // For now, remove each or just clear state if backend cleared via order
    state = [];
  }

  double get subtotal => state.fold(0, (sum, item) => sum + item.totalPrice);
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  final repository = ref.watch(batteryPurchaseRepositoryProvider);
  return CartNotifier(repository);
});
