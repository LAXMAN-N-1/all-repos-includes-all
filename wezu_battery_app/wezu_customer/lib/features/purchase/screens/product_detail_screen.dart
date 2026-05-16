import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/battery_product.dart';
import '../providers/purchase_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'cart_screen.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final BatteryProduct product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  BatteryVariant? _selectedVariant;
  final int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
    final displayedPrice = _selectedVariant?.price ?? widget.product.price;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(cartCount),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainInfo(),
                  const SizedBox(height: 32),
                  if (widget.product.variants.isNotEmpty) ...[
                    _buildVariantSection('Available Variations', _buildVariantSelector()),
                    const SizedBox(height: 32),
                  ],
                  _buildSpecifications(),
                  const SizedBox(height: 32),
                  _buildKeyFeatures(),
                  SizedBox(height: Responsive.isMobile(context) ? 120 : 32), // Bottom bar space
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(cartNotifier, displayedPrice),
    );
  }

  Widget _buildAppBar(int cartCount) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: AppTheme.surfaceDark,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.black26,
          child: Icon(LucideIcons.chevronLeft, size: 20, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.black26,
            child: Icon(LucideIcons.share2, size: 18, color: Colors.white),
          ),
          onPressed: () {},
        ),
        Stack(
          children: [
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black26,
                child: Icon(LucideIcons.shoppingCart, size: 18, color: Colors.white),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              ),
            ),
            if (cartCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: widget.product.imageUrls.isNotEmpty ? widget.product.imageUrls.first : '',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.product.brand.toUpperCase(),
              style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.product.inStock ? AppTheme.accentGreen.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.product.inStock ? 'IN STOCK' : 'OUT OF STOCK',
                style: TextStyle(
                  color: widget.product.inStock ? AppTheme.accentGreen : Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.product.name,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(LucideIcons.star, color: Colors.orange, size: 18),
            const SizedBox(width: 4),
            Text(
              '${widget.product.rating}',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Text(
              '(${widget.product.reviewCount} Reviews)',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildInfoChip(LucideIcons.shieldCheck, '${widget.product.warrantyMonths}m Warranty'),
            const SizedBox(width: 12),
            _buildInfoChip(LucideIcons.zap, '${widget.product.capacityMah} mAh'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVariantSection(String title, Widget selector) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        selector,
      ],
    );
  }

  Widget _buildVariantSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.product.variants.map((variant) {
        final isSelected = _selectedVariant?.id == variant.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedVariant = variant),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryBlue : AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.white10),
            ),
            child: Column(
              children: [
                Text(
                  variant.name,
                  style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                ),
                Text(
                   '₹${variant.price.toInt()}',
                  style: TextStyle(color: isSelected ? Colors.white70 : AppTheme.accentGreen, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpecifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: widget.product.specifications.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    Text(entry.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFeatures() {
    final features = widget.product.keyFeatures.isNotEmpty 
      ? widget.product.keyFeatures 
      : ['High energy density', 'Fast charging support', 'Eco-friendly disposal', 'Extreme temperature resistance'];
      
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Icon(LucideIcons.checkCircle2, color: AppTheme.accentGreen, size: 16),
              const SizedBox(width: 12),
              Expanded(child: Text(feature, style: const TextStyle(color: Colors.white70, fontSize: 14))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildBottomBar(CartNotifier cartNotifier, double price) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price per Unit', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text(
                  '₹${price.toInt()}',
                  style: const TextStyle(color: AppTheme.accentGreen, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                cartNotifier.addItem(widget.product, variant: _selectedVariant, quantity: _quantity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Added to cart successfully'),
                    action: SnackBarAction(
                      label: 'VIEW CART',
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('ADD TO CART', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}