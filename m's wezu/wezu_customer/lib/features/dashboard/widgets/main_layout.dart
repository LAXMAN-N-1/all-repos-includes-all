import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../../maps/screens/station_locator_screen.dart';
import '../../purchase/screens/shop_home_screen.dart';
import '../../rental/screens/my_rentals_screen.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../payment/screens/wallet_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StationLocatorScreen(),
    const ShopHomeScreen(),
    const MyRentalsScreen(),
    const WalletScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // Central FAB
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.heroGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: "main_nav_shop_fab",
          onPressed: () => _onItemTapped(2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.shoppingBag,
                  color: Colors.white, size: 22),
              const SizedBox(height: 2),
              Text("Shop",
                  style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Glass bottom nav
      bottomNavigationBar: Container(
        height: 96,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                  child: Container(
                    height: 66,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.glassDarkStrong
                          : AppColors.glassWhiteStrong,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      border: Border.all(
                        color: isDark
                            ? AppColors.glassBorderDark
                            : AppColors.glassBorderLight,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.25 : 0.04),
                          blurRadius: 32,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, LucideIcons.home, "Home", isDark),
                        _buildNavItem(
                            1, LucideIcons.mapPin, "Discover", isDark),
                        const SizedBox(width: 40), // Space for FAB
                        _buildNavItem(3, LucideIcons.battery, "Rentals", isDark,
                            hasBadge: true),
                        _buildNavItem(4, LucideIcons.wallet, "Wallet", isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark,
      {bool hasBadge = false}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? (isDark ? Colors.white : AppColors.primary)
        : (isDark ? Colors.white.withValues(alpha: 0.35) : AppColors.textHint);

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      child: SizedBox(
        width: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(icon, color: color, size: 21),
                ),
                if (hasBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 3),
                height: 4,
                width: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
