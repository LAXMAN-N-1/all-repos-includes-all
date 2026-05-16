import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bouncy_card.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';
import '../providers/purchase_providers.dart';
import '../models/battery_product.dart';

class ShopHomeScreen extends ConsumerWidget {
  const ShopHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productsAsync = ref.watch(batteryProductsProvider);
    final cart = ref.watch(cartProvider);
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, ref, isDark, cart.length),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildFeaturedBanner(context, ref),
                const SizedBox(height: 32),
                _buildSectionHeader("Shop by Category"),
                _buildCategoriesGrid(context, ref),
                const SizedBox(height: 32),
                _buildSectionHeader("Best Sellers", trailing: _buildSortDropdown(context, ref)),
                productsAsync.when(
                  data: (products) => _buildProductGrid(context, isDark, products, ref),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                const SizedBox(height: 32),
                _buildExclusiveBanner(context, ref),
                SizedBox(height: Responsive.isMobile(context) ? 120 : 32), // Space for Floating Nav
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, bool isDark, int cartCount) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 60,
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
      elevation: 0,
      title: Container(
        height: 45,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (value) => ref.read(batterySearchQueryProvider.notifier).state = value,
          decoration: InputDecoration(
            hintText: "Search products...",
            hintStyle: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
            prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppTheme.primaryBlue),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(LucideIcons.shoppingCart, color: AppTheme.primaryBlue),
              onPressed: () => context.push('/cart_screen'), 
            ),
            if (cartCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
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
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text("Summer of Energy", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 180,
          child: PageView(
            controller: PageController(viewportFraction: 0.9),
            children: [
              _buildBannerItem(
                "Up to 30% OFF", 
                "Premium Lithium Cells", 
                AppTheme.primaryBlue,
                "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=500",
                () {
                  final filters = ref.read(batteryFiltersProvider);
                  ref.read(batteryFiltersProvider.notifier).state = {
                    ...filters,
                    'category': 'EV Battery',
                  };
                }
              ),
              _buildBannerItem(
                "New Arrival", 
                "Smart Home Energy Hub", 
                const Color(0xFF6366F1),
                "https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?w=500",
                () {
                  final filters = ref.read(batteryFiltersProvider);
                  ref.read(batteryFiltersProvider.notifier).state = {
                    ...filters,
                    'category': 'Solar Hub',
                  };
                }
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(String title, String subtitle, Color color, String imageUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.2,
              child: Icon(LucideIcons.zap, size: 150, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text("LIMITED TIME", style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 8),
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.8), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text("Shop Now", style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(batteryFiltersProvider);
    final currentSort = filters['sortBy'] as String? ?? 'featured';

    return DropdownButton<String>(
      value: currentSort,
      underline: const SizedBox(),
      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppTheme.primaryBlue),
      style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
      items: const [
        DropdownMenuItem(value: 'featured', child: Text('Featured')),
        DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
        DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
        DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
      ],
      onChanged: (val) {
        if (val != null) {
          ref.read(batteryFiltersProvider.notifier).state = {
            ...filters,
            'sortBy': val,
          };
        }
      },
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, WidgetRef ref) {
    final categories = [
      {'name': 'EV Battery', 'icon': LucideIcons.car, 'color': AppTheme.primaryBlue},
      {'name': 'Solar Hub', 'icon': LucideIcons.sun, 'color': Colors.amber},
      {'name': 'Adapters', 'icon': LucideIcons.plug, 'color': Colors.green},
      {'name': 'Inverters', 'icon': LucideIcons.zap, 'color': Colors.indigo},
    ];

    final currentCategory = ref.watch(batteryFiltersProvider)['category'] as String? ?? 'All';

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final catName = cat['name'] as String;
          final isSelected = currentCategory == catName || (currentCategory == 'All' && index == 0);
          
          return BouncyCard(
            onTap: () {
              final filters = ref.read(batteryFiltersProvider);
              ref.read(batteryFiltersProvider.notifier).state = {
                ...filters,
                'category': index == 0 ? 'All' : catName,
              };
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Row(
                  children: [
                    Icon(cat['icon'] as IconData, color: isSelected ? Colors.white : Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      catName, 
                      style: GoogleFonts.outfit(
                        fontSize: 13, 
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey
                      )
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, bool isDark, List<BatteryProduct> products, WidgetRef ref) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text("No products found", style: GoogleFonts.outfit(color: Colors.grey)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.gridColumns(context),
        childAspectRatio: 0.72,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(context, isDark, products[index], ref);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, bool isDark, BatteryProduct product, WidgetRef ref) {
    final hasImage = product.imageUrls.isNotEmpty;
    
    return BouncyCard(
      onTap: () => context.push('/product_details/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.shadowLight,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      image: hasImage ? DecorationImage(
                        image: NetworkImage(product.imageUrls[0]),
                        fit: BoxFit.cover,
                      ) : null,
                    ),
                    child: !hasImage ? const Center(child: Icon(LucideIcons.image, color: Colors.grey)) : null,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.heart, size: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text("${product.brand} | ${product.capacityMah / 1000}Ah", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹${product.price.toStringAsFixed(0)}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue)),
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${product.name} added to cart"),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(LucideIcons.shoppingCart, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExclusiveBanner(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final filters = ref.read(batteryFiltersProvider);
        ref.read(batteryFiltersProvider.notifier).state = {
          ...filters,
          'category': 'Solar Hub',
        };
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.gift, color: AppTheme.primaryBlue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Exclusive Launch Offer", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Get free installation on all solar hubs", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppTheme.primaryBlue),
        ],
      ),
    ),
  );
}
}