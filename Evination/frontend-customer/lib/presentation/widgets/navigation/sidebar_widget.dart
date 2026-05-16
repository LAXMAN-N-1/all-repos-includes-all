import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:evination_customer_app/app/routes.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth/auth_notifier.dart';

class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Container(
      width: 256,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Logo
          _buildHeader(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Main Menu
                   _buildSectionTitle('MAIN MENU'),
                   const SizedBox(height: 8),
                   _buildNavItem(
                     context,
                     label: 'Home',
                     icon: Icons.home_outlined,
                     route: AppRouter.home,
                     isActive: currentRoute == AppRouter.home,
                   ),
                   const SizedBox(height: 8),
                   _buildNavItem(
                     context,
                     label: 'Previous Events',
                     icon: Icons.access_time,
                     route: AppRouter.events,
                     isActive: currentRoute == AppRouter.events,
                   ),
                   const SizedBox(height: 8),
                   _buildNavItem(
                     context,
                     label: 'Notifications',
                     icon: Icons.notifications_outlined,
                     route: AppRouter.notifications,
                     isActive: currentRoute == AppRouter.notifications,
                     hasBadge: true,
                   ),

                   const SizedBox(height: 32),
                   
                   // Account
                   _buildSectionTitle('ACCOUNT'),
                   const SizedBox(height: 8),
                   _buildNavItem(
                     context,
                     label: 'My Profile',
                     icon: Icons.person_outline,
                     route: AppRouter.profile,
                     isActive: currentRoute == AppRouter.profile,
                   ),
                   const SizedBox(height: 8),
                   _buildNavItem(
                     context,
                     label: 'My Bookings',
                     icon: Icons.calendar_today_outlined,
                     route: AppRouter.bookings,
                     isActive: currentRoute == AppRouter.bookings,
                   ),
                   const SizedBox(height: 8),
                   _buildNavItem(
                     context,
                     label: 'Settings',
                     icon: Icons.settings_outlined,
                     route: AppRouter.settings,
                     isActive: currentRoute == AppRouter.settings,
                   ),
                ],
              ),
            ),
          ),

          // User Profile Footer
          _buildUserProfile(context, ref, user),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.luxuryGradient,
              borderRadius: BorderRadius.circular(14), 
              boxShadow: [
                 BoxShadow(
                   color: AppColors.sunflowerYellow.withValues(alpha: 0.3),
                   blurRadius: 15,
                   offset: const Offset(0, 8),
                 ),
              ],
            ),
            child: const Icon(Icons.flash_on, color: Colors.white, size: 24), 
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                 'EVE NATION',
                 style: GoogleFonts.cormorantGaramond(
                   color: AppColors.darkCharcoal,
                   fontSize: 22,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 1.2,
                 ),
               ),
               Text(
                 'Customer Portal',
                 style: GoogleFonts.outfit(
                   color: AppColors.greyMedium,
                   fontSize: 10,
                   fontWeight: FontWeight.w500,
                   letterSpacing: 0.5,
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: AppColors.greyMedium,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
    required bool isActive,
    bool hasBadge = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.sunflowerYellow.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.sunflowerYellow.withValues(alpha: 0.3) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.sunflowerYellow : AppColors.greyMedium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: isActive ? AppColors.darkCharcoal : AppColors.greyDark,
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (hasBadge)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.sunflowerYellow,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, WidgetRef ref, dynamic user) {
    final initial = user?.firstName?.isNotEmpty == true 
        ? user!.firstName![0].toUpperCase() 
        : (user?.username?.isNotEmpty == true ? user!.username![0].toUpperCase() : 'A');
        
    final fullName = user != null
        ? '${user.firstName ?? user.username} ${user.lastName ?? ""}'.trim()
        : 'Guest User';
        
    final role = user?.role ?? 'customer';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
           Container(
             width: 36,
             height: 36,
             decoration: BoxDecoration(
               gradient: AppColors.luxuryGradient,
               borderRadius: BorderRadius.circular(10),
             ),
             child: Center(
               child: Text(
                 initial,
                 style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
               ),
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   fullName,
                   style: GoogleFonts.outfit(
                     color: AppColors.darkCharcoal,
                     fontSize: 14,
                     fontWeight: FontWeight.w500,
                   ),
                   overflow: TextOverflow.ellipsis,
                 ),
                 Text(
                   role,
                   style: GoogleFonts.outfit(
                     color: AppColors.greyMedium,
                     fontSize: 12,
                   ),
                 ),
               ],
             ),
           ),
           IconButton(
             onPressed: () {
               ref.read(authProvider.notifier).logout();
               context.go(AppRouter.login);
             },
             icon: Icon(Icons.logout_rounded, size: 20, color: AppColors.greyMedium),
             tooltip: 'Logout',
           ),
        ],
      ),
    );
  }
}
