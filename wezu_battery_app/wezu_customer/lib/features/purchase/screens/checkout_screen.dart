import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/purchase_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'order_success_screen.dart';
import '../../payment/providers/wallet_provider.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/models/address_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/routing/app_router.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'UPI';
  int _selectedAddressIndex = 0;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(profileProvider.notifier).loadAddresses(force: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final profileState = ref.watch(profileProvider);
    final addresses = profileState.addresses;
    final selectedAddressIndex =
        (_selectedAddressIndex >= 0 && _selectedAddressIndex < addresses.length)
            ? _selectedAddressIndex
            : 0;
    final userPhone = ref.watch(authProvider).user?.phoneNumber;
    final total = cartNotifier.subtotal;

    return GlassScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Checkout',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Delivery Address'),
            const SizedBox(height: 16),
            if (profileState.isAddressLoading && addresses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                ),
              )
            else if (addresses.isEmpty)
              _buildEmptyAddressCard()
            else
              ...addresses.asMap().entries.map(
                    (entry) => _buildAddressCard(
                      entry.key,
                      entry.value,
                      phoneNumber: userPhone,
                      isSelected: entry.key == selectedAddressIndex,
                    ),
                  ),
            const SizedBox(height: 32),
            _buildSectionTitle('Payment Method'),
            const SizedBox(height: 16),
            _buildPaymentOption(
                'UPI', LucideIcons.smartphone, 'Google Pay, PhonePe, Paytm'),
            _buildPaymentOption(
                'Card', LucideIcons.creditCard, 'Debit / Credit Card'),
            _buildPaymentOption(
                'Cash', LucideIcons.banknote, 'Cash on Delivery'),
            const SizedBox(height: 32),
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 16),
            _buildOrderSummary(cartItems),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(total),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAddressCard(
    int index,
    AddressModel address, {
    required bool isSelected,
    String? phoneNumber,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration(
          true,
          borderWidth: 1.0,
        ).copyWith(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
              color: isSelected ? AppTheme.primaryBlue : Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isSelected ? AppTheme.primaryBlue : Colors.white24,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.title.isNotEmpty
                        ? address.title
                        : 'Address ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phoneNumber?.isNotEmpty == true
                        ? phoneNumber!
                        : 'Phone number not available',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAddressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration(
        true,
        borderWidth: 1.0,
      ).copyWith(border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No saved address found',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a delivery address to continue checkout.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.addresses);
              if (mounted) {
                ref.read(profileProvider.notifier).loadAddresses(force: true);
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primaryBlue),
              foregroundColor: Colors.white,
            ),
            child: const Text('Manage Addresses'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String id, IconData icon, String subtitle) {
    final isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration(
          true,
          borderWidth: 1.0,
        ).copyWith(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
              color: isSelected ? AppTheme.primaryBlue : Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(id,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(LucideIcons.check,
                  color: AppTheme.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(List<CartItem> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration(true).copyWith(
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.product.name}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${item.totalPrice.toInt()}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBottomBar(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(true).copyWith(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Payable',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              Text('₹${total.toInt()}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isPlacingOrder ? null : _handlePlaceOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: _isPlacingOrder
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('PLACE ORDER',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlaceOrder() async {
    setState(() => _isPlacingOrder = true);
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    final addresses = ref.read(profileProvider).addresses;
    if (addresses.isEmpty) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a delivery address first.')),
      );
      return;
    }

    final selectedAddress = addresses[
        (_selectedAddressIndex >= 0 && _selectedAddressIndex < addresses.length)
            ? _selectedAddressIndex
            : 0];
    final phone = ref.read(authProvider).user?.phoneNumber?.trim() ?? '';
    if (phone.isEmpty) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update your profile phone number before checkout.'),
        ),
      );
      return;
    }

    final cartNotifier = ref.read(cartProvider.notifier);
    final total = cartNotifier.subtotal;

    // Process wallet payment if selected
    if (_selectedPaymentMethod == 'UPI' || _selectedPaymentMethod == 'Wallet') {
      final success = await ref
          .read(walletProvider.notifier)
          .pay(total, description: 'Battery Purchase');
      if (!success) {
        if (!mounted) return;
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Payment failed. Insufficient limits.')));
        return;
      }
    }

    final shippingAddress = _buildShippingAddress(selectedAddress, phone);

    // Create real order in backend from persistent cart
    final orderData =
        await ref.read(batteryPurchaseRepositoryProvider).checkoutFromCart(
              shippingAddress: shippingAddress,
              paymentMethod: _selectedPaymentMethod,
            );

    if (!mounted) return;

    if (orderData != null) {
      await cartNotifier.clear();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(
                  orderId: orderData['order_number']?.toString() ??
                      'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  amount: total,
                )),
        (route) => route.isFirst,
      );
    } else {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to place order. Please try again.')),
      );
    }
  }

  Map<String, String> _buildShippingAddress(
    AddressModel address,
    String phone,
  ) {
    final parsed = _parseAddress(address.fullAddress);
    return {
      'address': parsed['address']!.isNotEmpty
          ? parsed['address']!
          : address.fullAddress,
      'city': parsed['city']!,
      'state': parsed['state']!,
      'pincode': parsed['pincode']!,
      'phone': phone,
    };
  }

  Map<String, String> _parseAddress(String fullAddress) {
    final parts = fullAddress
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return {
        'address': fullAddress,
        'city': '',
        'state': '',
        'pincode': '',
      };
    }

    var pincode = '';
    var state = '';
    var city = '';

    final tail = parts.last;
    final pinMatch = RegExp(r'(\d{5,6})').firstMatch(tail);
    if (pinMatch != null) {
      pincode = pinMatch.group(1)!;
      state = tail.replaceAll(pincode, '').replaceAll('-', '').trim();
    }

    if (parts.length >= 2) {
      city = parts[parts.length - 2];
    }
    if (state.isEmpty && parts.length >= 3) {
      state = parts[parts.length - 3];
    }

    final addressOnly = parts.length > 2
        ? parts.sublist(0, parts.length - 2).join(', ')
        : parts.first;

    return {
      'address': addressOnly,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}
