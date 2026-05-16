import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';
import '../../repositories/cart_repository.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepository _cartRepository;

  CartViewModel({required CartRepository cartRepository})
    : _cartRepository = cartRepository {
    _cartRepository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _cartRepository.removeListener(notifyListeners);
    super.dispose();
  }

  List<CartItem> get items => _cartRepository.items;
  double get totalAmount => _cartRepository.totalAmount;

  void updateQuantity(String id, int quantity) {
    _cartRepository.updateQuantity(id, quantity);
  }

  void removeItem(String id) {
    _cartRepository.removeItem(id);
  }

  void checkout() {
    // Implement checkout logic (e.g., navigate to payment or clear cart)
    _cartRepository.clearCart();
    // In real app, this would trigger navigation or API call
  }
}
