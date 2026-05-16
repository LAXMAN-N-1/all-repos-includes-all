import 'package:flutter/material.dart';

class CartService extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;

  void addItem(String name, double price) {
    _items.add({'name': name, 'price': price, 'qty': 1});
    notifyListeners();
  }
  
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
