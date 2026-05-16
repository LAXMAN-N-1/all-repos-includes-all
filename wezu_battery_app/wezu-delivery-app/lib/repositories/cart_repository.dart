import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';

class CartRepository extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.total);

  CartRepository() {
    _loadMockData();
  }

  void _loadMockData() {
    _items = [
      CartItem(
        id: '1',
        name: 'Wezu Helmet',
        price: 1200.0,
        quantity: 1,
        imageUrl: 'assets/images/helmet.png', // Placeholder
      ),
      CartItem(
        id: '2',
        name: 'Delivery Bag',
        price: 850.0,
        quantity: 1,
        imageUrl: 'assets/images/bag.png', // Placeholder
      ),
    ];
    notifyListeners();
  }

  void addItem(CartItem item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (quantity <= 0) {
        removeItem(id);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
