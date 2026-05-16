import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';

class DeliveryVerificationViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;

  String _orderId = '';
  String _otp = '';
  File? _proofImage;
  bool _isLoading = false;
  String? _errorMessage;

  String get otp => _otp;
  File? get proofImage => _proofImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DeliveryVerificationViewModel({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  void setOrderId(String id) {
    _orderId = id;
  }

  void setOtp(String value) {
    _otp = value;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      _proofImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  /// Verify delivery by:
  /// 1. Uploading proof of delivery image (if any)
  /// 2. Calling POST /logistics/orders/{id}/pod with pod_url and otp
  /// 3. Updating order status to 'delivered'
  Future<bool> verifyDelivery({String? orderId}) async {
    if (orderId != null && orderId.trim().isNotEmpty) {
      _orderId = orderId.trim();
    }

    if (_otp.length != 6) {
      _errorMessage = 'Please enter a valid 6-digit OTP';
      notifyListeners();
      return false;
    }
    if (_orderId.isEmpty) {
      _errorMessage = 'Order ID not set';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Upload pod and verify OTP against backend
      final podUrl = _proofImage?.path ?? '';
      final success = await _orderRepository.uploadPod(
        _orderId,
        podUrl: podUrl,
        otp: _otp,
      );

      if (success) {
        // Mark order as delivered
        await _orderRepository.updateOrderStatus(
          _orderId,
          OrderStatus.delivered,
        );
        return true;
      } else {
        _errorMessage = 'Invalid OTP or delivery verification failed.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Verification failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProofImage() {
    _proofImage = null;
    notifyListeners();
  }
}
