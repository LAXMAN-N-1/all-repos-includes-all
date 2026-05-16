import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/battery_product.dart';
import '../providers/purchase_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'product_detail_screen.dart';
import 'cart_screen.dart';

class PurchaseCatalogScreen extends ConsumerWidget {
  const PurchaseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(batteryProductsProvider);
    final metadataAsync = ref.watch(batteryCatalogMetadataProvider);
    final cartItems = ref.watch(cartProvider);
    final cartCount = cartItems.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref, cartCount),
            _buildCategoryBar(ref, metadataAsync),
            Expanded(
              child: productsAsync.when(
                data: (products) => products.isEmpty
                    ? _buildEmptyState()
                    : _buildProductGrid(context, products, ref),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                ),
                error: (e, stack) => Center(
                  child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, int cartCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buy a Battery',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.shoppingCart, color: Colors.white),
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
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      ref.read(batterySearchQueryProvider.notifier).state = value;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search batteries by brand, mAh...",
                      hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(LucideIcons.search, color: AppTheme.primaryBlue, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterButton(context, ref),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: IconButton(
        icon: const Icon(LucideIcons.sliders, color: AppTheme.primaryBlue, size: 20),
        onPressed: () => _showFilterSheet(context, ref),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    // Implementation of Screen 1A (Filter Sheet)
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => _FilterSheet(ref: ref),
    );
  }

  Widget _buildCategoryBar(WidgetRef ref, AsyncValue<Map<String, dynamic>> metadataAsync) {
    final filters = ref.watch(batteryFiltersProvider);
    
    return metadataAsync.when(
      data: (metadata) {
        final categories = ['All', ...(metadata['categories'] as List<dynamic>? ?? [])];
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index].toString();
              final isSelected = filters['category'] == category;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(batteryFiltersProvider.notifier).state = {
                      ...filters,
                      'category': selected ? category : 'All',
                    };
                  },
                  backgroundColor: AppTheme.surfaceDark,
                  selectedColor: AppTheme.primaryBlue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 60),
      error: (_, __) => const SizedBox(height: 60),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<BatteryProduct> products, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.gridColumns(context),
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(product: product);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.batteryWarning, size: 80, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'No batteries found',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Try adjusting your search or filters', style: TextStyle(color: Colors.white24, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final BatteryProduct product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(color: Colors.grey[900]),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.capacityMah} mAh',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
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
                  Text(
                    product.brand.toUpperCase(),
                    style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.originalPrice != null)
                            Text(
                              '₹${product.originalPrice?.toInt()}',
                              style: const TextStyle(color: Colors.white24, fontSize: 10, decoration: TextDecoration.lineThrough),
                            ),
                          Text(
                            '₹${product.price.toInt()}',
                            style: const TextStyle(color: AppTheme.accentGreen, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(LucideIcons.plus, color: Colors.white, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () {
                            ref.read(cartProvider.notifier).addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppTheme.primaryBlue,
                              ),
                            );
                          },
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
}

class _FilterSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _FilterSheet({required this.ref});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late Map<String, dynamic> _localFilters;

  @override
  void initState() {
    super.initState();
    _localFilters = {...widget.ref.read(batteryFiltersProvider)};
  }

  @override
  Widget build(BuildContext context) {
    final metadata = widget.ref.watch(batteryCatalogMetadataProvider).value ?? {};
    final brands = metadata['brands'] as List<dynamic>? ?? [];
    
    return Container(
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters & Sorting',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _localFilters = {
                      'category': 'All',
                      'brand': 'All',
                      'min_price': null,
                      'max_price': null,
                      'sortBy': 'featured',
                    };
                  });
                },
                child: const Text('Reset', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          const Text('Sort By', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                {'label': 'Featured', 'value': 'featured'},
                {'label': 'Price: Low to High', 'value': 'price_asc'},
                {'label': 'Price: High to Low', 'value': 'price_desc'},
                {'label': 'Top Rated', 'value': 'rating'},
                {'label': 'Popularity', 'value': 'popularity'},
              ].map((option) {
                final isSelected = _localFilters['sortBy'] == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(option['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _localFilters['sortBy'] = option['value']);
                    },
                    backgroundColor: AppTheme.surfaceDark,
                    selectedColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                  ),
                );
              }).toList(),
            ),
          ),
          
          if (brands.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Brand', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['All', ...brands].map((brand) {
                final isSelected = _localFilters['brand'] == brand;
                return ChoiceChip(
                  label: Text(brand.toString()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _localFilters['brand'] = selected ? brand : 'All');
                  },
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              widget.ref.read(batteryFiltersProvider.notifier).state = _localFilters;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
