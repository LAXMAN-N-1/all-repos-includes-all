import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/order_model.dart';
import '../models/battery_model.dart';

class OfflineService {
  static const String _ordersBox = 'orders_cache';
  static const String _inventoryBox = 'inventory_cache';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_ordersBox);
    await Hive.openBox<String>(_inventoryBox);
  }

  // ─── Orders Cache ──────────────────────────────────────────────────

  static Future<void> cacheOrders(List<OrderModel> orders) async {
    final box = Hive.box<String>(_ordersBox);
    // Clear old cache or just overwrite
    // For simplicity, we'll store the whole list as one JSON string due to complex objects
    // Or store individually by ID. Let's store individually.
    
    final Map<String, String> entries = {
      for (var o in orders) o.id: jsonEncode(o.toJson())
    };
    await box.putAll(entries);
  }

  static List<OrderModel> getCachedOrders() {
    final box = Hive.box<String>(_ordersBox);
    return box.values
        .map((e) => OrderModel.fromJson(jsonDecode(e)))
        .toList();
  }

  // ─── Inventory Cache ───────────────────────────────────────────────

  static Future<void> cacheInventory(List<BatteryModel> batteries) async {
    final box = Hive.box<String>(_inventoryBox);
    final Map<String, String> entries = {
      for (var b in batteries) b.id: jsonEncode(b.toJson())
    };
    await box.putAll(entries);
  }

  static List<BatteryModel> getCachedInventory() {
    final box = Hive.box<String>(_inventoryBox);
    return box.values
        .map((e) => BatteryModel.fromJson(jsonDecode(e)))
        .toList();
  }
}
