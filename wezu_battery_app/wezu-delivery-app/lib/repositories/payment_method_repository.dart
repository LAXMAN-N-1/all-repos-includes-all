import 'package:flutter/material.dart';
import '../models/payment_method_model.dart';
import '../services/payment_method_service.dart';

/// Global ChangeNotifier that owns the saved payment methods list.
/// Registered in main.dart via ChangeNotifierProvider so every screen
/// can read/mutate without prop-drilling.
class PaymentMethodRepository extends ChangeNotifier {
  final PaymentMethodService _service;

  List<PaymentMethod> _methods = [];
  bool _isLoading = false;
  String? _error;

  // Last used auth token (set via [setAuthToken]).
  String _authToken = '';

  PaymentMethodRepository({PaymentMethodService? service})
    : _service = service ?? PaymentMethodService();

  // ── Getters ────────────────────────────────────────────────────────────────

  List<PaymentMethod> get methods => List.unmodifiable(_methods);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  PaymentMethod? get defaultMethod {
    try {
      return _methods.firstWhere((m) => m.isDefault);
    } catch (_) {
      return _methods.isNotEmpty ? _methods.first : null;
    }
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  void setAuthToken(String token) {
    _authToken = token;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> fetchMethods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _methods = await _service.fetchMethods(_authToken);
      // Sort: default first, then cards before UPI, then by id
      _methods.sort((a, b) {
        if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
        if (a.type != b.type) {
          return a.type == PaymentMethodType.card ? -1 : 1;
        }
        return a.id.compareTo(b.id);
      });
    } catch (e) {
      _error = 'Failed to load payment methods.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marks [id] as the default and persists.
  Future<void> setDefault(String id) async {
    // Optimistic update
    _methods = _methods.map((m) => m.copyWith(isDefault: m.id == id)).toList();
    // Re-sort so default is first
    _methods.sort((a, b) {
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      return 0;
    });
    notifyListeners();

    await _service.setDefault(id, _authToken);
  }

  /// Removes the method with [id].
  Future<void> deleteMethod(String id) async {
    final previous = List<PaymentMethod>.from(_methods);
    _methods.removeWhere((m) => m.id == id);

    // If we deleted the default, promote the next one
    if (previous.any((m) => m.id == id && m.isDefault) && _methods.isNotEmpty) {
      _methods[0] = _methods[0].copyWith(isDefault: true);
    }
    notifyListeners();

    final ok = await _service.deleteMethod(id, _authToken);
    if (!ok) {
      // Rollback
      _methods = previous;
      notifyListeners();
    }
  }

  /// Adds a new UPI method (card path uses gateway token — mocked for now).
  Future<void> addUpiMethod(String upiId) async {
    final method = await _service.addMethod(
      authToken: _authToken,
      type: 'upi',
      upiId: upiId,
    );
    if (method != null) {
      _methods.add(method);
      notifyListeners();
    }
  }

  Future<void> addCardMethodMock({
    required String last4,
    required CardBrand brand,
    required String expiryMonth,
    required String expiryYear,
  }) async {
    // In production this would use a real payment gateway token.
    final method = PaymentMethod(
      id: 'pm_local_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentMethodType.card,
      last4: last4,
      brand: brand,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      isDefault: false,
    );
    _methods.add(method);
    notifyListeners();
  }

  /// Clears state on logout.
  void resetForLogout() {
    _methods = [];
    _isLoading = false;
    _error = null;
    _authToken = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
