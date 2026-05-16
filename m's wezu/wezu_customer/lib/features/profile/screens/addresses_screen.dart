import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../models/address_model.dart';

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(profileProvider.notifier).loadAddresses(force: true),
    );
  }

  @override
  void dispose() {
    // Force clear any active snackbars when leaving this screen
    // to prevent them from "following" the user to other screens.
    ScaffoldMessenger.of(context).clearSnackBars();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Saved Addresses',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.withValues(alpha: 0.12),
          ),
        ),
      ),
      body: profileState.isAddressLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            )
          : profileState.addresses.isEmpty
              ? _buildEmptyState(isDark)
              : _buildAddressList(profileState.addresses, isDark),
      floatingActionButton: _buildAddFab(),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.mapPin,
                size: 56,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No Saved Addresses',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add your home, work or any frequently\nvisited address for faster checkout.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              onPressed: _navigateToAddAddress,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(
                'Add New Address',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Address List ─────────────────────────────────────────────────────────

  Widget _buildAddressList(List<AddressModel> addresses, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        return _buildAddressCard(addresses[index], isDark);
      },
    );
  }

  // ─── Address Card ─────────────────────────────────────────────────────────

  Widget _buildAddressCard(AddressModel address, bool isDark) {
    return Dismissible(
      key: Key('addr_${address.id}'),
      direction: DismissDirection.endToStart,
      background: _buildSwipeDeleteBackground(),
      confirmDismiss: (_) => _confirmDelete(address),
      onDismissed: (_) => _deleteAddress(address),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: address.isDefault
              ? Border.all(
                  color: Colors.green.withValues(alpha: 0.4), width: 1.5)
              : Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _iconColorForType(address.title).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _iconForType(address.title),
              color: _iconColorForType(address.title),
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  address.title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.checkCircle,
                          size: 11, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Default',
                        style: GoogleFonts.outfit(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              address.fullAddress,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.grey[500],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: _buildKebabMenu(address, isDark),
        ),
      ),
    );
  }

  // ─── Kebab Menu ────────────────────────────────────────────────────────────

  Widget _buildKebabMenu(AddressModel address, bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(
        LucideIcons.moreVertical,
        size: 20,
        color: isDark ? Colors.white54 : Colors.grey[500],
      ),
      onSelected: (value) async {
        if (value == 'default') {
          await _setDefault(address);
        } else if (value == 'delete') {
          final confirmed = await _confirmDelete(address);
          if (confirmed == true) {
            _deleteAddress(address);
          }
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 8,
      itemBuilder: (context) => [
        if (!address.isDefault)
          PopupMenuItem<String>(
            value: 'default',
            child: Row(children: [
              const Icon(LucideIcons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 10),
              Text('Set as Default',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ]),
          ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(children: [
            const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
            const SizedBox(width: 10),
            Text('Delete',
                style: GoogleFonts.outfit(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ]),
        ),
      ],
    );
  }

  // ─── Swipe Delete Background ──────────────────────────────────────────────

  Widget _buildSwipeDeleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.trash2, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text('Delete',
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────

  Widget _buildAddFab() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddAddress,
      icon: const Icon(LucideIcons.plus, size: 20),
      label: Text(
        'Add New Address',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppTheme.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'work':
        return LucideIcons.briefcase;
      case 'other':
        return LucideIcons.mapPin;
      default:
        return LucideIcons.home;
    }
  }

  Color _iconColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'work':
        return Colors.purple;
      case 'other':
        return Colors.orange;
      default:
        return AppTheme.primaryBlue;
    }
  }

  void _navigateToAddAddress() async {
    await Navigator.pushNamed(context, AppRoutes.addAddress);
    // Refresh after returning from add screen
    if (mounted) {
      ref.read(profileProvider.notifier).loadAddresses(force: true);
    }
  }

  Future<bool?> _confirmDelete(AddressModel address) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Address',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Remove "${address.title}" from your saved addresses?',
          style: GoogleFonts.outfit(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.outfit()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Delete',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteAddress(AddressModel address) {
    ref.read(profileProvider.notifier).deleteAddress(address.id);

    // Ensure we manage the SnackBar after the current frame to avoid conflicts with Dismissible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final scaf = ScaffoldMessenger.of(context);
      scaf.hideCurrentSnackBar();
      scaf.showSnackBar(
        SnackBar(
          content:
              Text('${address.title} removed', style: GoogleFonts.outfit()),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              ref.read(profileProvider.notifier).loadAddresses(force: true);
            },
          ),
        ),
      );
    });
  }

  Future<void> _setDefault(AddressModel address) async {
    try {
      await ref.read(profileProvider.notifier).setDefaultAddress(address.id);
      if (mounted) {
        final scaf = ScaffoldMessenger.of(context);
        scaf.hideCurrentSnackBar();
        scaf.showSnackBar(
          SnackBar(
            content: Text('"${address.title}" set as default address',
                style: GoogleFonts.outfit()),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update default: $e',
                style: GoogleFonts.outfit()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
