import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:evination_customer_app/app/routes.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:evination_customer_app/presentation/providers/auth/auth_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.sunflowerYellow, AppColors.goldenAmber],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
              child: Column(
                children: [
                   Container(
                     padding: const EdgeInsets.all(4),
                     decoration: const BoxDecoration(
                       shape: BoxShape.circle,
                       color: Colors.white,
                     ),
                     child: CircleAvatar(
                       radius: 50,
                       backgroundColor: AppColors.warmWhite,
                       backgroundImage: user?.profilePhoto != null 
                           ? NetworkImage(user!.profilePhoto!) 
                           : null,
                       child: user?.profilePhoto == null 
                           ? Text(
                               (user?.username[0] ?? 'U').toUpperCase(),
                               style: GoogleFonts.cormorantGaramond(
                                 fontSize: 40,
                                 fontWeight: FontWeight.bold,
                                 color: AppColors.sunflowerYellow
                               )
                             )
                           : null,
                     ),
                   ),
                   const SizedBox(height: 24),
                   Text(
                     user != null 
                         ? '${user.firstName ?? user.username} ${user.lastName ?? ""}'.trim() 
                         : 'Guest User',
                     style: GoogleFonts.cormorantGaramond(
                       fontSize: 36, 
                       fontWeight: FontWeight.bold, 
                       color: Colors.white
                     )
                   ),
                   const SizedBox(height: 8),
                   Text(
                     user?.email ?? 'Please log in', 
                     style: GoogleFonts.outfit(
                       fontSize: 14, 
                       color: Colors.white.withValues(alpha: 0.8),
                       letterSpacing: 0.5
                     )
                   ),
                    const SizedBox(height: 24),
                    if (user != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              (user.role).toUpperCase(), 
                              style: GoogleFonts.outfit(
                                color: Colors.white, 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0
                              )
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),

            // 2. Options List
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                     BoxShadow(
                       color: Colors.black.withValues(alpha: 0.05),
                       blurRadius: 20,
                       offset: const Offset(0, -4),
                     )
                  ]
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildSectionHeader('Account'),
                    const SizedBox(height: 16),
                    _buildOptionTile(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      subtitle: 'Update your profile details',
                      onTap: () {},
                    ),
                    _buildOptionTile(
                      icon: Icons.history,
                      title: 'Booking History',
                      subtitle: 'View past and upcoming bookings',
                      onTap: () => context.push(AppRouter.bookings),
                    ),
                    _buildOptionTile(
                      icon: Icons.favorite_border,
                      title: 'Saved Vendors',
                       subtitle: 'Your favorite service providers',
                      onTap: () {},
                    ),
                     const SizedBox(height: 32),
                    _buildSectionHeader('Settings'),
                     const SizedBox(height: 16),
                    _buildOptionTile(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      subtitle: 'Manage alerts and messages',
                      onTap: () => context.push(AppRouter.notifications),
                    ),
                    _buildOptionTile(
                      icon: Icons.payment,
                      title: 'Payment Methods',
                       subtitle: 'Manage cards and billing',
                      onTap: () {},
                    ),
                    _buildOptionTile(
                      icon: Icons.lock_outline,
                      title: 'Security',
                       subtitle: 'Password and account validation',
                      onTap: () {},
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Support'),
                     const SizedBox(height: 16),
                    _buildOptionTile(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                       subtitle: 'FAQs and Support Chat',
                      onTap: () {},
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(authProvider.notifier).logout();
                          context.go(AppRouter.login);
                        },
                         icon: const Icon(Icons.logout, size: 20),
                         label: Text('LOG OUT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.sunflowerYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            color: AppColors.greyDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.0
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.sunflowerYellow.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.sunflowerYellow, size: 22),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.darkCharcoal)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.greyMedium),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
