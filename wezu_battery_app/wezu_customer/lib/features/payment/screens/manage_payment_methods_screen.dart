import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/wallet_provider.dart';
import '../models/payment_models.dart';

class ManagePaymentMethodsScreen extends ConsumerStatefulWidget {
  const ManagePaymentMethodsScreen({super.key});

  @override
  ConsumerState<ManagePaymentMethodsScreen> createState() =>
      _ManagePaymentMethodsScreenState();
}

class _ManagePaymentMethodsScreenState
    extends ConsumerState<ManagePaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Payment Methods',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: walletState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGreen))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saved Methods',
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 16),
                  if (walletState.savedMethods.isEmpty)
                    _buildEmptyState(isDark)
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: walletState.savedMethods.length,
                        itemBuilder: (context, index) => _buildMethodItem(
                            walletState.savedMethods[index], isDark),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildAddButton(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(LucideIcons.creditCard,
              size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No saved payment methods',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMethodItem(SavedPaymentMethod method, bool isDark) {
    final bool isCard = method.type == SavedPaymentMethodType.card;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowLight,
        border: method.isDefault
            ? Border.all(color: AppTheme.primaryBlue, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Icon(isCard ? LucideIcons.creditCard : LucideIcons.atSign,
              color: AppTheme.primaryBlue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    isCard
                        ? '${method.brand} •••• ${method.last4}'
                        : method.upiId!,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black)),
                if (method.isDefault)
                  const Text('Default Method',
                      style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
            onPressed: () => _confirmDelete(method),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SavedPaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Method?'),
        content:
            const Text('Are you sure you want to remove this payment method?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // TODO: Implement delete in provider
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _showAddMethodOptions(),
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Add New Method',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showAddMethodOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading:
                const Icon(LucideIcons.creditCard, color: AppTheme.primaryBlue),
            title: const Text('Add Credit/Debit Card'),
            onTap: () {
              Navigator.pop(context);
              // Implement card addition (SDK tokenization)
            },
          ),
          ListTile(
            leading:
                const Icon(LucideIcons.atSign, color: AppTheme.primaryBlue),
            title: const Text('Add UPI ID'),
            onTap: () {
              Navigator.pop(context);
              // Implement UPI addition
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
